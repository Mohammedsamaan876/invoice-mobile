import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/company/presentation/company_profile_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/invoices/presentation/screens/create_invoice_screen.dart';
import '../../features/invoices/presentation/screens/invoice_list_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String shell = '/';
  static const String login = '/login';
  static const String invoices = '/invoices';
  static const String createInvoice = '/invoices/create';
  static const String customers = '/customers';
  static const String products = '/products';
  static const String company = '/company';
  static const String settings = '/settings';
}

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.shell:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.invoices:
        return MaterialPageRoute(builder: (_) => const InvoiceListScreen());
      case AppRoutes.createInvoice:
        return MaterialPageRoute(builder: (_) => const CreateInvoiceScreen());
      case AppRoutes.customers:
        return MaterialPageRoute(builder: (_) => const CustomersScreen());
      case AppRoutes.products:
        return MaterialPageRoute(builder: (_) => const ProductsScreen());
      case AppRoutes.company:
        return MaterialPageRoute(builder: (_) => const CompanyProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
