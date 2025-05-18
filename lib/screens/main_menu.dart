import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../ui/background.dart';
import 'menu_editor_screen.dart';
import 'table_scan_screen.dart';
import 'kitchen_screen.dart';
import 'cashier_screen.dart';

class MainMenu extends StatelessWidget {
  final List<_RoleMenu> roles = [
    _RoleMenu(
      title: "Menu Editor",
      subtitle: "Manage menu categories & items",
      color: Colors.deepPurple,
      icon: Icons.restaurant_menu,
      routeBuilder: (_) => MenuEditorScreen(),
    ),
    _RoleMenu(
      title: "Waiter",
      subtitle: "Scan table & place orders",
      color: Colors.blue,
      icon: Icons.qr_code_scanner,
      routeBuilder: (_) => TableScanScreen(),
    ),
    _RoleMenu(
      title: "Cashier",
      subtitle: "Process orders & payments",
      color: Colors.green,
      icon: Icons.point_of_sale,
      routeBuilder: (_) => CashierScreen(),
    ),
    _RoleMenu(
      title: "Kitchen",
      subtitle: "View & prepare orders",
      color: Colors.orange,
      icon: Icons.kitchen,
      routeBuilder: (_) => KitchenScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Listen to all orders (OrderProvider provided at root)
    final orders = Provider.of<OrderProvider>(context).orders;

    // Calculate total sales for all 'paid' orders
    double totalSales = orders
        .where((o) => o.status == 'paid')
        .fold(0.0, (sum, o) => sum + o.total);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedWebBackground()),
          // Total sales badge at top-right
          Positioned(
            top: 36,
            right: 32,
            child: _TotalSalesBadge(totalSales: totalSales),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    margin: EdgeInsets.only(top: 16, bottom: 28),
                    child: Text(
                      "Welcome!\nChoose your role:",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.97),
                        letterSpacing: 1.3,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ...roles.map((role) => _GlassRoleCard(role: role)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalSalesBadge extends StatelessWidget {
  final double totalSales;
  const _TotalSalesBadge({required this.totalSales});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 26, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.27),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.green.withOpacity(0.17), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.attach_money, color: Colors.green[700], size: 25),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Sales",
                    style: TextStyle(
                      fontSize: 13.7,
                      color: Colors.green[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "RM ${totalSales.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassRoleCard extends StatelessWidget {
  final _RoleMenu role;
  const _GlassRoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: role.routeBuilder),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: role.color.withOpacity(0.15),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: role.color,
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              width: double.infinity,
              constraints: BoxConstraints(minWidth: 250, maxWidth: 400, minHeight: 110),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: role.color.withOpacity(0.23),
                    ),
                    padding: EdgeInsets.all(18),
                    child: Icon(
                      role.icon,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                blurRadius: 7,
                                color: Colors.black.withOpacity(0.18),
                                offset: Offset(1, 2),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          role.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 15.2,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleMenu {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final WidgetBuilder routeBuilder;

  _RoleMenu({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.routeBuilder,
  });
}
