import UserNotifications

import OneSignalFramework

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var receivedRequest: UNNotificationRequest!
    var bestAttemptContent: UNMutableNotificationContent?
    private var hasDeliveredContent = false

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        hasDeliveredContent = false
        self.receivedRequest = request
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard bestAttemptContent != nil else {
            contentHandler(request.content)
            return
        }

        OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)

        guard let imageURLString = resolveImageURL(from: request.content.userInfo),
              let imageURL = URL(string: imageURLString) else {
            deliverBestAttemptContent()
            return
        }

        downloadAttachment(from: imageURL) { [weak self] attachment in
            guard let self = self else {
                return
            }

            if let attachment,
               let bestAttemptContent = self.bestAttemptContent,
               bestAttemptContent.attachments.isEmpty {
                bestAttemptContent.attachments = [attachment]
            }

            self.deliverBestAttemptContent()
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if bestAttemptContent != nil {
            OneSignal.serviceExtensionTimeWillExpireRequest(self.receivedRequest, with: self.bestAttemptContent)
        }

        deliverBestAttemptContent()
    }

    private func deliverBestAttemptContent() {
        guard !hasDeliveredContent else {
            return
        }

        hasDeliveredContent = true
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func resolveImageURL(from userInfo: [AnyHashable: Any]) -> String? {
        let keys = [
            "image",
            "image_url",
            "imageurl",
            "big_picture",
            "bigpicture",
            "ios_image",
            "attachment",
            "attachment_url",
        ]

        if let directURL = findImageURL(in: userInfo, preferredKeys: keys) {
            return directURL
        }

        if let custom = userInfo["custom"] as? [String: Any],
           let customURL = findImageURL(in: custom, preferredKeys: keys) {
            return customURL
        }

        if let additionalData = (userInfo["custom"] as? [String: Any])?["a"] as? [String: Any],
           let additionalDataURL = findImageURL(in: additionalData, preferredKeys: keys) {
            return additionalDataURL
        }

        if let attachments = userInfo["ios_attachments"] as? [String: Any],
           let attachmentURL = attachments.values.first(where: { $0 is String }) as? String,
           !attachmentURL.isEmpty {
            return attachmentURL
        }

        if let attachments = userInfo["ios_attachments"] as? [Any],
           let attachmentURL = attachments.first(where: { $0 is String }) as? String,
           !attachmentURL.isEmpty {
            return attachmentURL
        }

        return nil
    }

    private func findImageURL(in dictionary: [String: Any], preferredKeys: [String]) -> String? {
        for key in preferredKeys {
            if let value = dictionary[key] as? String,
               value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                return value
            }
        }

        for value in dictionary.values {
            if let nested = value as? [String: Any],
               let nestedURL = findImageURL(in: nested, preferredKeys: preferredKeys) {
                return nestedURL
            }
        }

        return nil
    }

    private func findImageURL(in dictionary: [AnyHashable: Any], preferredKeys: [String]) -> String? {
        var normalized = [String: Any]()
        for (key, value) in dictionary {
            normalized[String(describing: key).lowercased()] = value
        }

        return findImageURL(in: normalized, preferredKeys: preferredKeys)
    }

    private func downloadAttachment(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let session = URLSession(configuration: .ephemeral)
        session.dataTask(with: url) { data, response, _ in
            guard let data else {
                completion(nil)
                return
            }

            let fileExtension = self.resolveFileExtension(from: response) ?? "jpg"
            let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(fileExtension)

            do {
                try data.write(to: fileURL, options: .atomic)
                let attachment = try UNNotificationAttachment(identifier: "image", url: fileURL)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    private func resolveFileExtension(from response: URLResponse?) -> String? {
        guard let httpResponse = response as? HTTPURLResponse,
              let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")?.lowercased() else {
            return nil
        }

        if contentType.contains("image/png") {
            return "png"
        }
        if contentType.contains("image/gif") {
            return "gif"
        }
        if contentType.contains("image/webp") {
            return "webp"
        }
        if contentType.contains("image/heic") {
            return "heic"
        }
        if contentType.contains("image/jpeg") || contentType.contains("image/jpg") {
            return "jpg"
        }

        return nil
    }
}