enum UserRole { admin, student }

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  bool isApproved;
  int fineAmount;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isApproved = false,
    this.fineAmount = 0,
  });
}

class BookingEntry {
  final String userId;
  final DateTime date;
  final String category; // 'office' or 'remote'
  bool isApproved;
  bool showedUp;
  bool isFinalized;

  BookingEntry({
    required this.userId,
    required this.date,
    required this.category,
    this.isApproved = false,
    this.showedUp = false,
    this.isFinalized = false,
  });
}
