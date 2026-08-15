import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_service.dart';
import 'models.dart';
import 'package:intl/intl.dart';

class AppDialogs {
  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController identifierController = TextEditingController(); // Email or Phone
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isValidPhone(String phone) {
    return RegExp(r'^\d{10,13}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: ds.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We Connect Seats',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isLogin ? 'Welcome Back!' : 'Create Account',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                if (!isLogin) ...[
                  const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  isLogin ? 'Email or Phone Number' : 'Email Address', 
                  style: const TextStyle(fontWeight: FontWeight.w500)
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: identifierController,
                  validator: (v) {
                    if (v!.isEmpty) return 'This field is required';
                    if (!isLogin && !v.contains('@')) return 'Enter a valid email address';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: isLogin ? 'name@mail.com or 03xxxxxxxxx' : 'name@example.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 16),
                  const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => !_isValidPhone(v!) ? 'Phone must be 10-13 digits' : null,
                    decoration: InputDecoration(
                      hintText: '03001234567',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                if (!isLogin) ...[
                  const SizedBox(height: 16),
                  const Text('Note: All new accounts are registered as STUDENTS and require admin approval.', 
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      String? err;
                      if (isLogin) {
                        err = await ds.login(identifierController.text, passwordController.text);
                      } else {
                        err = await ds.register(
                          nameController.text, 
                          identifierController.text, 
                          phoneController.text,
                          passwordController.text,
                          UserRole.student
                        );
                      }
                      
                      if (!context.mounted) return;

                      if (err != null) {
                        AppDialogs.showError(context, err);
                      } else if (!isLogin) {
                        setState(() => isLogin = true);
                        AppDialogs.showSuccess(context, 'Registration successful! Please login.');
                      }
                    },
                    child: Text(isLogin ? 'Login' : 'Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? "Don't have an account? Sign Up" : 'Already have an account? Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final user = ds.currentUser!;
    
    final List<Widget> pages = [
      _buildHome(context, ds, user),
      const BookingChoiceScreen(),
      _buildHistory(context, ds, user),
      _buildProfile(context, ds, user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('We Connect Seats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_seat_outlined), selectedIcon: Icon(Icons.event_seat), label: 'Booking'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHome(BuildContext context, DataService ds, UserAccount user) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayRes = ds.reservations.where((r) => 
      r.userId == user.id && 
      r.date.year == today.year && 
      r.date.month == today.month && 
      r.date.day == today.day
    ).firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, ${user.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          if (!user.isApproved)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(child: Text('Your account is pending approval by the admin.')),
                ],
              ),
            ),
          
          if (todayRes != null && !todayRes.isApproved)
            Card(
              color: Colors.blue.shade50,
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.pending_actions, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(child: Text('Your booking for today is pending admin approval.')),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),
          const Text('Your Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Daily Fines',
                  value: 'Rs. ${user.fineAmount}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.red.shade50,
                  textColor: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Today Status',
                  value: todayRes != null ? (todayRes.isApproved ? 'Approved' : 'Pending') : 'None',
                  icon: Icons.bookmark_outline,
                  color: const Color(0xFFE8F0FE),
                  textColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'Book Today',
            subtitle: 'Choose Office or Remote',
            icon: Icons.event_seat,
            onTap: () => setState(() => _currentIndex = 1),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'View Fine History',
            subtitle: 'Check your attendance record',
            icon: Icons.history_edu,
            onTap: () => setState(() => _currentIndex = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(BuildContext context, DataService ds, UserAccount user) {
    final userRes = ds.reservations.where((r) => r.userId == user.id).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userRes.length,
      itemBuilder: (context, index) {
        final res = userRes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: res.showedUp ? Colors.green.shade50 : Colors.red.shade50,
              child: Icon(res.showedUp ? Icons.check : Icons.close, color: res.showedUp ? Colors.green : Colors.red),
            ),
            title: Text('Reservation on ${DateFormat('MMM dd, yyyy').format(res.date)} (${res.category.toUpperCase()})'),
            subtitle: Text(res.showedUp ? 'Attended' : (res.isApproved ? 'No-show (Fine applied)' : 'Not approved')),
          ),
        );
      },
    );
  }

  Widget _buildProfile(BuildContext context, DataService ds, UserAccount user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Center(
          child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
        ),
        const SizedBox(height: 16),
        Center(child: Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        Center(child: Text(user.email)),
        Center(child: Text(user.phone, style: const TextStyle(color: Colors.grey))),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => ds.logout(),
        ),
      ],
    );
  }
}

class BookingChoiceScreen extends StatefulWidget {
  const BookingChoiceScreen({super.key});

  @override
  State<BookingChoiceScreen> createState() => _BookingChoiceScreenState();
}

class _BookingChoiceScreenState extends State<BookingChoiceScreen> {
  String? selectedType; // 'office' or 'remote'

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final user = ds.currentUser!;
    final today = DateTime.now();
    final todayRes = ds.reservations.where((r) => 
      r.userId == user.id && 
      r.date.year == today.year && 
      r.date.month == today.month && 
      r.date.day == today.day
    ).firstOrNull;

    if (todayRes != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                todayRes.category == 'office' ? Icons.business : Icons.laptop_chromebook, 
                size: 80, 
                color: const Color(0xFF003C90)
              ),
              const SizedBox(height: 24),
              Text(
                'Today\'s ${todayRes.category.toUpperCase()} booking',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Text(
                todayRes.isApproved ? 'Status: Approved' : 'Status: Pending Admin Approval',
                style: TextStyle(
                  color: todayRes.isApproved ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (selectedType == 'office') {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () => setState(() => selectedType = null), 
              icon: const Icon(Icons.arrow_back), 
              label: const Text('Switch to Remote Option')
            ),
          ),
          const Expanded(child: SeatBookingScreen()),
        ],
      );
    }

    if (selectedType == 'remote') {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              onPressed: () => setState(() => selectedType = null), 
              icon: const Icon(Icons.arrow_back), 
              label: const Text('Switch to Office Option')
            ),
          ),
          const Expanded(child: RemoteRegistrationScreen()),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('How will you work today?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          _ChoiceCard(
            title: 'At the Office',
            subtitle: 'Reserve a physical seat',
            icon: Icons.business,
            onTap: () => setState(() => selectedType = 'office'),
          ),
          const SizedBox(height: 20),
          _ChoiceCard(
            title: 'Remote / Online',
            subtitle: 'Join the virtual section',
            icon: Icons.laptop_chromebook,
            onTap: () => setState(() => selectedType = 'remote'),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC3C6D5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF003C90)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class RemoteRegistrationScreen extends StatelessWidget {
  const RemoteRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final user = ds.currentUser!;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.laptop_chromebook, size: 80, color: Color(0xFF003C90)),
            const SizedBox(height: 24),
            const Text('Remote Section Registration', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Section Time: ${ds.remoteStartTime.format(context)} to ${ds.remoteEndTime.format(context)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: !user.isApproved ? null : () async {
                  final err = await ds.reserveSeat(isRemote: true);
                  if (context.mounted) {
                    if (err == null) {
                      AppDialogs.showSuccess(context, 'Remote registration requested! Wait for approval.');
                    } else {
                      AppDialogs.showError(context, err);
                    }
                  }
                },
                child: const Text('Confirm Remote Registration'),
              ),
            ),
            if (!user.isApproved)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'Account must be approved by admin first.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SeatBookingScreen extends StatefulWidget {
  const SeatBookingScreen({super.key});

  @override
  State<SeatBookingScreen> createState() => _SeatBookingScreenState();
}

class _SeatBookingScreenState extends State<SeatBookingScreen> {
  int? selectedSeatIndex;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    final totalSeats = ds.totalSeats;
    final reservations = ds.reservations.where((r) => 
      r.date.year == today.year && r.date.month == today.month && r.date.day == today.day && r.category == 'office'
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Software House Floor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('Booking Window: ${ds.officeReservationStartTime.format(context)} - ${ds.officeReservationEndTime.format(context)}'),
          const SizedBox(height: 12),
          const Text('Select a seat to reserve for today.'),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(color: const Color(0xFFF0FDF4), borderColor: const Color(0xFF22C55E), label: 'Available'),
              _LegendItem(color: const Color(0xFFDEE8FF), borderColor: const Color(0xFFC3C6D5), label: 'Occupied'),
              _LegendItem(color: theme.colorScheme.primary, borderColor: theme.colorScheme.primary, label: 'Selected'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: totalSeats,
            itemBuilder: (context, index) {
              bool isReserved = index < reservations.length;
              bool isSelected = selectedSeatIndex == index;
              
              return InkWell(
                onTap: isReserved ? null : () => setState(() => selectedSeatIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? theme.colorScheme.primary 
                      : (isReserved ? const Color(0xFFDEE8FF) : const Color(0xFFF0FDF4)),
                    border: Border.all(
                      color: isSelected 
                        ? theme.colorScheme.primary 
                        : (isReserved ? const Color(0xFFC3C6D5) : const Color(0xFF22C55E)),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ] : [],
                  ),
                  child: Center(
                    child: isReserved 
                      ? const Icon(Icons.close, size: 16, color: Color(0xFF737784))
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF111C2D),
                          ),
                        ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: (selectedSeatIndex == null || !ds.currentUser!.isApproved) ? null : () async {
                final error = await ds.reserveSeat();
                if (!context.mounted) return;
                if (error == null) {
                  AppDialogs.showSuccess(context, 'Seat requested! Waiting for admin approval.');
                  setState(() => selectedSeatIndex = null);
                } else {
                  AppDialogs.showError(context, error);
                }
              },
              child: const Text('Request Reservation'),
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    
    final List<Widget> pages = [
      const DailyReports(),
      const AdminReservationApprovals(),
      const UserManagement(),
      const SeatsManagement(),
      const AdminSettings(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('We Connect Seats Admin'),
        actions: [
          IconButton(
            tooltip: 'Add New Admin',
            icon: const Icon(Icons.person_add_alt_1_outlined), 
            onPressed: () => _showAddAdminDialog(context, ds),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => ds.logout()),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.settings_input_component_outlined), selectedIcon: Icon(Icons.settings_input_component), label: 'Seats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context, DataService ds) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Admin Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || phoneCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                AppDialogs.showError(context, 'All fields are required');
                return;
              }
              if (!emailCtrl.text.contains('@')) {
                AppDialogs.showError(context, 'Invalid email address');
                return;
              }

              final err = await ds.createSecondaryAdmin(nameCtrl.text, emailCtrl.text, phoneCtrl.text, passCtrl.text);
              if (context.mounted) {
                if (err == null) {
                  AppDialogs.showSuccess(context, 'Admin created successfully!');
                  Navigator.pop(context);
                } else {
                  AppDialogs.showError(context, err);
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class AdminReservationApprovals extends StatelessWidget {
  const AdminReservationApprovals({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final today = DateTime.now();
    final pending = ds.reservations.where((r) => 
      !r.isApproved && 
      r.date.year == today.year && 
      r.date.month == today.month && 
      r.date.day == today.day
    ).toList();

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pending.length,
        itemBuilder: (context, index) {
          final res = pending[index];
          final student = ds.users.firstWhere((u) => u.id == res.userId, orElse: () => UserAccount(id: res.userId, name: 'Unknown', email: '', phone: '', role: UserRole.student));
          return Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text('Requested ${res.category} booking for today'),
              trailing: ElevatedButton(
                onPressed: () async {
                  await ds.approveReservation(res.userId, res.date);
                  if (context.mounted) {
                    AppDialogs.showSuccess(context, 'Reservation approved');
                  }
                },
                child: const Text('Approve'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserManagement extends StatelessWidget {
  const UserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final allUsers = ds.users;
    final currentAdminId = ds.currentUser?.id;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allUsers.length,
      itemBuilder: (context, index) {
        final user = allUsers[index];
        final isMe = user.id == currentAdminId;
        final isAdmin = user.role == UserRole.admin;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAdmin ? Colors.blue.shade100 : Colors.green.shade100,
              child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person, 
                         color: isAdmin ? Colors.blue : Colors.green),
            ),
            title: Row(
              children: [
                Expanded(child: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                if (isMe) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    child: const Text('YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            subtitle: Text('${user.email}\n${user.phone}${isAdmin ? '' : '\nFine: Rs. ${user.fineAmount}'}'),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdmin && !user.isApproved)
                  IconButton(
                    tooltip: 'Approve User',
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () async {
                      final err = await ds.approveStudent(user.id);
                      if (context.mounted) {
                        if (err == null) {
                          AppDialogs.showSuccess(context, '${user.name} approved');
                        } else {
                          AppDialogs.showError(context, err);
                        }
                      }
                    },
                  ),
                if (!isAdmin)
                  IconButton(
                    tooltip: 'Promote to Admin',
                    icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.blue),
                    onPressed: () => _showPromoteDialog(context, ds, user),
                  ),
                if (!isAdmin)
                  IconButton(
                    tooltip: 'Edit Fine',
                    icon: const Icon(Icons.edit_note),
                    onPressed: () => _showFineDialog(context, ds, user),
                  ),
                if (!isMe)
                  IconButton(
                    tooltip: 'Delete User',
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteDialog(context, ds, user),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, DataService ds, UserAccount user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${user.role == UserRole.admin ? 'Admin' : 'Student'}?'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final err = await ds.deleteUserAccount(user.id);
              if (context.mounted) {
                if (err == null) {
                  AppDialogs.showSuccess(context, '${user.name} deleted successfully');
                  Navigator.pop(context);
                } else {
                  AppDialogs.showError(context, err);
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPromoteDialog(BuildContext context, DataService ds, UserAccount user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Admin?'),
        content: Text('Are you sure you want to promote ${user.name} to Admin? This will give them full control over the app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              final err = await ds.promoteToAdmin(user.id);
              if (context.mounted) {
                if (err == null) {
                  AppDialogs.showSuccess(context, '${user.name} promoted to Admin');
                  Navigator.pop(context);
                } else {
                  AppDialogs.showError(context, err);
                }
              }
            },
            child: const Text('Confirm Promotion'),
          ),
        ],
      ),
    );
  }

  void _showFineDialog(BuildContext context, DataService ds, UserAccount user) {
    final controller = TextEditingController(text: user.fineAmount.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Fine: ${user.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Fine Amount (Rs.)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newAmount = int.tryParse(controller.text);
              if (newAmount == null) {
                AppDialogs.showError(context, 'Please enter a valid number');
                return;
              }
              final err = await ds.updateFineAmount(user.id, newAmount);
              if (context.mounted) {
                if (err == null) {
                  AppDialogs.showSuccess(context, 'Fine updated for ${user.name}');
                  Navigator.pop(context);
                } else {
                  AppDialogs.showError(context, err);
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class SeatsManagement extends StatelessWidget {
  const SeatsManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final controller = TextEditingController(text: ds.totalSeats.toString());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Seats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('Define how many seats are available.'),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Number of Seats',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003C90),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                ds.setTotalSeats(int.tryParse(controller.text) ?? 20);
                AppDialogs.showSuccess(context, 'Total seats updated');
              },
              child: const Text('Update Capacity'),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 20),
          const Text('Danger Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          const Text('Clear all reservations made for today. This cannot be undone.'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showResetConfirm(context, ds),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Today\'s Seats'),
            ),
          )
        ],
      ),
    );
  }

  void _showResetConfirm(BuildContext context, DataService ds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Today\'s Seats?'),
        content: const Text('This will delete all seat reservations and remote registrations for TODAY. Approved students will need to book again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await ds.resetTodayBookings();
              if (context.mounted) {
                AppDialogs.showSuccess(context, 'Today\'s bookings have been reset.');
                Navigator.pop(context);
              }
            },
            child: const Text('Reset Now'),
          ),
        ],
      ),
    );
  }
}

class DailyReports extends StatelessWidget {
  const DailyReports({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final today = DateTime.now();
    final todayRes = ds.reservations.where((r) => 
      r.date.year == today.year && r.date.month == today.month && r.date.day == today.day
    ).toList();

    final officeRes = todayRes.where((r) => r.category == 'office').toList();
    final remoteRes = todayRes.where((r) => r.category == 'remote').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report for ${DateFormat('EEEE, MMM dd').format(today)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _ReportStatCard(
            label: 'Office Seats (Reserved)',
            value: '${officeRes.length} / ${ds.totalSeats}',
            percentage: ds.totalSeats > 0 ? officeRes.length / ds.totalSeats : 0,
          ),
          const SizedBox(height: 8),
          _ReportStatCard(
            label: 'Remote Students',
            value: '${remoteRes.length} Registered',
            percentage: 0,
          ),
          const SizedBox(height: 24),
          
          _buildAttendanceSection(context, ds, 'Office Attendance', officeRes.where((r) => r.isApproved).toList()),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Remote Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: () => _showFinalizeDialog(context, ds),
                child: const Text('Finalize All'),
              ),
            ],
          ),
          _buildAttendanceSection(context, ds, 'Remote Section Attendance', remoteRes.where((r) => r.isApproved).toList()),
        ],
      ),
    );
  }

  void _showFinalizeDialog(BuildContext context, DataService ds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Remote Section?'),
        content: const Text('All students who have not been marked present will be marked absent and fined Rs. 50.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await ds.finalizeRemoteSection();
              if (context.mounted) {
                AppDialogs.showSuccess(context, 'Section finalized. Fines applied to absentees.');
                Navigator.pop(context);
              }
            },
            child: const Text('Finalize & Fine'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(BuildContext context, DataService ds, String title, List<BookingEntry> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
        if (list.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No approved students.'),
          )),
        ...list.map((res) {
          final student = ds.users.firstWhere(
            (u) => u.id == res.userId, 
            orElse: () => UserAccount(id: res.userId, name: 'Unknown Student', email: '', phone: '', role: UserRole.student)
          );
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(res.showedUp ? 'Present' : (res.isFinalized ? 'Absent (Fine Charged)' : 'Pending')),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Mark Present',
                    icon: Icon(Icons.check_circle, color: res.showedUp ? Colors.green : Colors.grey),
                    onPressed: res.isFinalized ? null : () async {
                      final error = await ds.markAttendance(res.userId, res.date, true);
                      if (!context.mounted) return;
                      if (error != null) {
                        AppDialogs.showError(context, error);
                      } else {
                        AppDialogs.showSuccess(context, '${student.name} marked Present');
                      }
                    },
                  ),
                  IconButton(
                    tooltip: 'Mark Absent & Fine',
                    icon: Icon(Icons.cancel, color: !res.showedUp && res.isFinalized ? Colors.red : Colors.grey),
                    onPressed: res.isFinalized ? null : () async {
                      final error = await ds.markAttendance(res.userId, res.date, false);
                      if (!context.mounted) return;
                      if (error != null) {
                        AppDialogs.showError(context, error);
                      } else {
                        AppDialogs.showSuccess(context, '${student.name} marked Absent. Rs.${ds.defaultFineAmount} fine charged.');
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class AdminSettings extends StatelessWidget {
  const AdminSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    final fineController = TextEditingController(text: ds.defaultFineAmount.toString());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Global Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Default Absent Fine (Rs.)'),
          subtitle: Text('Currently: Rs. ${ds.defaultFineAmount}'),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              controller: fineController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '50'),
              onSubmitted: (v) {
                final val = int.tryParse(v);
                if (val != null) {
                  ds.setDefaultFineAmount(val);
                  AppDialogs.showSuccess(context, 'Fine amount updated');
                }
              },
            ),
          ),
        ),
        const Divider(height: 32),
        const Text('Office Reservation Window', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        _buildTimeTile(context, 'Reservation Start Time', ds.officeReservationStartTime, (t) => ds.setOfficeReservationTimes(t, ds.officeReservationEndTime)),
        _buildTimeTile(context, 'Reservation End Time', ds.officeReservationEndTime, (t) => ds.setOfficeReservationTimes(ds.officeReservationStartTime, t)),
        _buildTimeTile(context, 'Attendance Starting Time', ds.attendanceStartTime, (t) => ds.setAttendanceStartTime(t)),
        const Divider(height: 32),
        const Text('Remote Section Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        _buildTimeTile(context, 'Remote Start Time', ds.remoteStartTime, (t) => ds.setRemoteTimes(t, ds.remoteEndTime)),
        _buildTimeTile(context, 'Remote End Time', ds.remoteEndTime, (t) => ds.setRemoteTimes(ds.remoteStartTime, t)),
      ],
    );
  }

  Widget _buildTimeTile(BuildContext context, String title, TimeOfDay time, Function(TimeOfDay) onSelect) {
    return ListTile(
      title: Text(title),
      subtitle: Text('Current: ${time.format(context)}'),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time);
        if (t != null) {
          onSelect(t);
          if (context.mounted) {
            AppDialogs.showSuccess(context, '$title updated successfully');
          }
        }
      },
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final double percentage;

  const _ReportStatCard({required this.label, required this.value, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFC3C6D5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          if (percentage > 0) ...[
            LinearProgressIndicator(value: percentage, backgroundColor: const Color(0xFFDEE8FF), color: const Color(0xFF003C90), minHeight: 8, borderRadius: BorderRadius.circular(4)),
            const SizedBox(height: 8),
          ],
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color textColor;

  const _SummaryCard({required this.title, required this.value, required this.icon, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFE7EEFF), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF003C90)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFC3C6D5))),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendItem({required this.color, required this.borderColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
