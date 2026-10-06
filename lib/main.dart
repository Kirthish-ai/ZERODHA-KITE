import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'models/stock_model.dart';
import 'services/trading_service.dart';
import 'widgets/header_widget.dart';
import 'widgets/watchlist_widget.dart';
import 'widgets/stock_detail_widget.dart';
import 'widgets/chart_widget.dart';
import 'widgets/order_dialog.dart';
import 'widgets/orders_view.dart';
import 'widgets/portfolio_view.dart';
import 'widgets/pricing_calculator_view.dart';
import 'widgets/alerts_view.dart';
import 'widgets/account_statement_view.dart';
import 'widgets/login_page.dart';
import 'widgets/profile_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZerodhaKiteApp());
}

class ZerodhaKiteApp extends StatelessWidget {
  const ZerodhaKiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zerodha Kite - High Performance Trading Platform',
      debugShowCheckedModeBanner: false,
      theme: KiteTheme.darkTheme,
      home: const MainKiteScreen(),
    );
  }
}

class MainKiteScreen extends StatefulWidget {
  const MainKiteScreen({super.key});

  @override
  State<MainKiteScreen> createState() => _MainKiteScreenState();
}

class _MainKiteScreenState extends State<MainKiteScreen> {
  int _activeTab = 0;
  bool _isMobileMode = false;
  final TradingService _tradingService = TradingService();

  void _openOrderModal(StockItem stock, OrderSide side) {
    showDialog(
      context: context,
      builder: (ctx) => OrderDialog(stock: stock, initialSide: side),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tradingService,
      builder: (context, _) {
        // Auth check: Show Login Page if not logged in
        if (!_tradingService.isLoggedIn) {
          return LoginPage(
            onLoginSuccess: () {
              setState(() {
                _activeTab = 0;
              });
            },
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = _isMobileMode || screenWidth < 768;
        final currentStock = _tradingService.selectedStock ?? _tradingService.allStocks.first;

        if (isMobile) {
          return Scaffold(
            backgroundColor: KiteTheme.darkBg,
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: KiteTheme.darkBg,
                    border: Border.all(color: KiteTheme.border, width: screenWidth > 500 ? 2 : 0),
                    borderRadius: BorderRadius.circular(screenWidth > 500 ? 16 : 0),
                    boxShadow: screenWidth > 500
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      // Mobile Top Header Bar
                      Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: KiteTheme.headerBg,
                          border: Border(bottom: BorderSide(color: KiteTheme.border)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: KiteTheme.zerodhaOrange,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text('K', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('KITE MOBILE', style: TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart, size: 20, color: KiteTheme.kiteBlue),
                                  onPressed: () => _openOrderModal(currentStock, OrderSide.buy),
                                  tooltip: 'New Order',
                                ),
                                IconButton(
                                  icon: Icon(_isMobileMode ? Icons.desktop_windows : Icons.smartphone, size: 20, color: KiteTheme.zerodhaOrange),
                                  onPressed: () {
                                    setState(() {
                                      _isMobileMode = !_isMobileMode;
                                    });
                                  },
                                  tooltip: _isMobileMode ? 'Switch to Desktop Mode' : 'Switch to Mobile App',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Mobile Main View Body
                      Expanded(
                        child: _activeTab == 0
                            ? Column(
                                children: [
                                  // Stock Detail + Chart Area (75% of screen)
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        // Compact Stock Detail Header
                                        StockDetailWidget(
                                          stock: currentStock,
                                          onTrade: (side) => _openOrderModal(currentStock, side),
                                          compact: true,
                                        ),
                                        // Chart takes remaining space
                                        Expanded(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(top: BorderSide(color: KiteTheme.border)),
                                            ),
                                            child: ChartWidget(stock: currentStock),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Watchlist (25% of screen)
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        border: Border(top: BorderSide(color: KiteTheme.border, width: 2)),
                                      ),
                                      child: WatchlistWidget(
                                        onStockSelected: (stock) {
                                          setState(() {});
                                        },
                                        onOpenTrade: (stock, side) => _openOrderModal(stock, side),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _buildMainContent(currentStock),
                      ),

                      // Zerodha Kite Mobile Bottom Navigation Bar
                      Container(
                        height: 58,
                        decoration: const BoxDecoration(
                          color: KiteTheme.panelBg,
                          border: Border(top: BorderSide(color: KiteTheme.border)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(child: _buildMobileNavItem(0, 'Watchlist', Icons.format_list_bulleted_rounded)),
                            Expanded(child: _buildMobileNavItem(1, 'Orders', Icons.assignment_outlined)),
                            Expanded(child: _buildMobileNavItem(2, 'Holdings', Icons.work_outline)),
                            Expanded(child: _buildMobileNavItem(3, 'Positions', Icons.pie_chart_outline)),
                            Expanded(child: _buildMobileNavItem(6, 'Alerts', Icons.notifications_none_rounded)),
                            Expanded(child: _buildMobileNavItem(8, 'Profile', Icons.person_outline)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Desktop Layout
        return Scaffold(
          backgroundColor: KiteTheme.darkBg,
          body: Column(
            children: [
              HeaderWidget(
                activeTab: _activeTab,
                onTabSelected: (index) {
                  setState(() {
                    _activeTab = index;
                  });
                },
                onOpenOrderModal: () => _openOrderModal(currentStock, OrderSide.buy),
                onToggleMobileMode: () {
                  setState(() {
                    _isMobileMode = !_isMobileMode;
                  });
                },
                isMobileMode: _isMobileMode,
              ),

              Expanded(
                child: Row(
                  children: [
                    WatchlistWidget(
                      onStockSelected: (stock) {
                        setState(() {});
                      },
                      onOpenTrade: (stock, side) => _openOrderModal(stock, side),
                    ),

                    Expanded(
                      child: _buildMainContent(currentStock),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileNavItem(int index, String label, IconData icon) {
    bool isSelected = _activeTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? KiteTheme.zerodhaOrange : KiteTheme.textMuted,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? KiteTheme.zerodhaOrange : KiteTheme.textMuted,
              fontSize: 9,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(StockItem currentStock) {
    switch (_activeTab) {
      case 0:
        return Column(
          children: [
            StockDetailWidget(
              stock: currentStock,
              onTrade: (side) => _openOrderModal(currentStock, side),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ChartWidget(stock: currentStock),
              ),
            ),
          ],
        );
      case 1:
        return const OrdersView();
      case 2:
        return const PortfolioView(isPositions: false);
      case 3:
        return const PortfolioView(isPositions: true);
      case 4:
        return const AccountStatementView();
      case 5:
        return const PricingCalculatorView();
      case 6:
        return const AlertsView();
      case 7:
        return const AccountStatementView();
      case 8:
        return ProfileView(
          onLogout: () {
            setState(() {
              _activeTab = 0;
            });
          },
        );
      default:
        return const Center(child: Text('Page under construction'));
    }
  }
}
