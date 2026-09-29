import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

class DashboardBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  const DashboardBottomNavigation({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (onDestinationSelected != null) {
          onDestinationSelected!(index);
          return;
        }

        if (index == selectedIndex) return;

        if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.shell,
            (route) => false,
          );
        } else if (index == 1) {
          Navigator.pushNamed(context, AppRoutes.invoices);
        } else if (index == 2) {
          Navigator.pushNamed(context, AppRoutes.customers);
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coming soon'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Invoices',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Customers',
        ),
        NavigationDestination(
          icon: Icon(Icons.more_horiz_outlined),
          selectedIcon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
    );
  }
}
