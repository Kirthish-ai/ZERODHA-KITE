import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/stock_model.dart';
import 'firebase_service.dart';

class TradingService extends ChangeNotifier {
  static final TradingService _instance = TradingService._internal();
  factory TradingService() => _instance;

  TradingService._internal() {
    _restoreSessionFromLocalStorage();
    _initData();
    _startWebSocketStream();
  }

  void _saveSessionToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_userProfile.toJson());
      await prefs.setString('kite_logged_in', 'true');
      await prefs.setString('kite_user_profile', jsonStr);
      debugPrint('Saved session to local storage for email: ${_userProfile.email}');
    } catch (e) {
      debugPrint('Error saving session to local storage: $e');
    }
  }

  void _restoreSessionFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? isLoggedInStr = prefs.getString('kite_logged_in');
      String? profileJsonStr = prefs.getString('kite_user_profile');

      if (isLoggedInStr == 'true' && profileJsonStr != null && profileJsonStr.isNotEmpty) {
        _isLoggedIn = true;
        _userProfile = UserProfile.fromJson(jsonDecode(profileJsonStr));
        debugPrint('Session restored for user: ${_userProfile.email}');
      }
    } catch (e) {
      debugPrint('Error restoring session from local storage: $e');
    }
  }

  final List<StockItem> _stocks = [];
  final Map<int, List<String>> _watchlists = {
    0: ['RELIANCE', 'TCS', 'HDFCBANK', 'INFYS', 'TATAMOTORS', 'NIFTY 50', 'BANKNIFTY'],
    1: ['ICICIBANK', 'BHARTIARTL', 'NIFTY 24500 CE', 'NIFTY 24400 PE'],
    2: ['TCS', 'INFYS'],
    3: ['RELIANCE', 'TATAMOTORS'],
    4: ['HDFCBANK', 'ICICIBANK'],
  };

  int _selectedWatchlistIndex = 0;
  StockItem? _selectedStock;

  final List<OrderItem> _orders = [];
  final List<HoldingItem> _holdings = [];
  final List<PositionItem> _positions = [];
  final List<PriceAlert> _alerts = [];
  final AccountFunds _funds = AccountFunds(
    availableMargin: 245890.50,
    usedMargin: 34110.00,
    totalCollateral: 150000.00,
    openingBalance: 280000.50,
    payinToday: 0.0,
  );

  Timer? _wsTimer;
  final StreamController<StockItem> _tickStreamController = StreamController<StockItem>.broadcast();
  Stream<StockItem> get tickStream => _tickStreamController.stream;
  final List<String> notifications = [];

  bool _isLoggedIn = false;
  UserProfile _userProfile = UserProfile(
    userId: 'AB1234',
    userName: 'Kirthish Shetty',
    email: 'kirthish.shetty@zerodha.sample',
    phone: '+91 98765 43210',
    pan: 'ABCDE1234F',
    avatarInitials: 'KS',
    dematDpId: '1208160012345678',
    bankName: 'HDFC Bank Ltd',
    bankAccountNo: '•••• •••• 4321',
    memberSince: DateTime(2021, 5, 14),
  );

  bool get isLoggedIn => _isLoggedIn;
  UserProfile get userProfile => _userProfile;

  bool login(String email, String password) {
    if (email.contains('@') && password.isNotEmpty) {
      _isLoggedIn = true;
      String name = email.split('@')[0];
      String initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'ZE';
      
      _userProfile = UserProfile(
        userId: 'AB${Random().nextInt(8999) + 1000}',
        userName: email.toLowerCase().contains('kirthish') ? 'Kirthish Shetty' : name,
        email: email.trim(),
        phone: '+91 98765 43210',
        pan: 'ABCDE${Random().nextInt(8999) + 1000}F',
        avatarInitials: initials,
        dematDpId: '1208160012345678',
        bankName: 'HDFC Bank Ltd',
        bankAccountNo: '•••• •••• 4321',
        memberSince: DateTime.now(),
      );
      _saveSessionToLocalStorage();
      notifications.insert(0, "Logged in successfully as ${email.trim()}");
      FirebaseService().syncUserProfile(_userProfile);
      notifyListeners();
      return true;
    }
    return false;
  }

  void loginWithFirestoreVerification({
    required String email,
    required String password,
    required Function(bool success, String? error) onComplete,
  }) {
    FirebaseService().verifyUserInFirestore(
      email: email,
      password: password,
      onComplete: (success, error, fetchedProfile) {
        if (success && fetchedProfile != null) {
          _isLoggedIn = true;
          _userProfile = fetchedProfile;
          _saveSessionToLocalStorage();
          notifications.insert(0, "Logged in from Firestore: ${fetchedProfile.email}");
          notifyListeners();
          onComplete(true, null);
        } else {
          onComplete(false, error ?? 'Account not found in Firestore. Please click "Signup for Kite" to register first.');
        }
      },
    );
  }

  void createAccountAndLogin({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required Function(bool success, String? error) onComplete,
  }) {
    FirebaseService().createAccountInFirestore(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      onComplete: (success, error, createdProfile) {
        if (success) {
          _isLoggedIn = true;
          if (createdProfile != null) {
            _userProfile = createdProfile;
          }
          _saveSessionToLocalStorage();
          notifications.insert(0, "Account created in Firestore for $email");
          notifyListeners();
          onComplete(true, null);
        } else {
          onComplete(false, error);
        }
      },
    );
  }

  void logout() async {
    _isLoggedIn = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('kite_logged_in');
      await prefs.remove('kite_user_profile');
    } catch (e) {
      debugPrint('Error clearing session from local storage: $e');
    }
    notifications.insert(0, "User logged out");
    notifyListeners();
  }

  // Getters
  List<StockItem> get allStocks => _stocks;
  int get selectedWatchlistIndex => _selectedWatchlistIndex;
  StockItem? get selectedStock => _selectedStock;
  List<OrderItem> get orders => _orders;
  List<HoldingItem> get holdings => _holdings;
  List<PositionItem> get positions => _positions;
  List<PriceAlert> get alerts => _alerts;
  AccountFunds get funds => _funds;

  List<StockItem> get currentWatchlistStocks {
    final symbols = _watchlists[_selectedWatchlistIndex] ?? [];
    return _stocks.where((s) => symbols.contains(s.symbol)).toList();
  }

  void selectWatchlist(int index) {
    _selectedWatchlistIndex = index;
    notifyListeners();
  }

  void selectStock(StockItem stock) {
    _selectedStock = stock;
    notifyListeners();
  }

  void _initData() {
    final now = DateTime.now();

    // Generate historic candles
    List<CandleData> generateCandles(double startPrice) {
      List<CandleData> list = [];
      double price = startPrice;
      DateTime time = now.subtract(const Duration(hours: 5));
      final rand = Random();
      for (int i = 0; i < 40; i++) {
        double open = price;
        double change = (rand.nextDouble() - 0.48) * (startPrice * 0.008);
        double close = open + change;
        double high = max(open, close) + rand.nextDouble() * (startPrice * 0.003);
        double low = min(open, close) - rand.nextDouble() * (startPrice * 0.003);
        double vol = (rand.nextInt(50) + 10) * 100.0;
        list.add(CandleData(
          time: time.add(Duration(minutes: i * 5)),
          open: double.parse(open.toStringAsFixed(2)),
          high: double.parse(high.toStringAsFixed(2)),
          low: double.parse(low.toStringAsFixed(2)),
          close: double.parse(close.toStringAsFixed(2)),
          volume: vol,
        ));
        price = close;
      }
      return list;
    }

    // Default Stock List
    _stocks.addAll([
      StockItem(
        symbol: 'NIFTY 50',
        name: 'NIFTY 50 Index',
        exchange: 'NSE',
        lastPrice: 24530.40,
        change: 112.50,
        changePercent: 0.46,
        open: 24430.00,
        high: 24560.00,
        low: 24410.00,
        prevClose: 24417.90,
        volume: 45890000,
        fundamentals: CompanyFundamentals(
          peRatio: 22.4,
          pbRatio: 3.8,
          marketCapCr: 18500000,
          dividendYield: 1.2,
          roe: 15.4,
          week52High: 26277.35,
          week52Low: 21280.00,
          eps: 1095.10,
          sectorPE: 22.0,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 154000, totalSellQty: 142000),
        candles: generateCandles(24420.0),
      ),
      StockItem(
        symbol: 'BANKNIFTY',
        name: 'NIFTY Bank Index',
        exchange: 'NSE',
        lastPrice: 52180.75,
        change: 210.30,
        changePercent: 0.40,
        open: 51990.00,
        high: 52300.00,
        low: 51950.00,
        prevClose: 51970.45,
        volume: 28900000,
        fundamentals: CompanyFundamentals(
          peRatio: 16.8,
          pbRatio: 2.1,
          marketCapCr: 9800000,
          dividendYield: 0.9,
          roe: 14.2,
          week52High: 54467.35,
          week52Low: 44429.00,
          eps: 3106.00,
          sectorPE: 16.5,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 98000, totalSellQty: 105000),
        candles: generateCandles(52000.0),
      ),
      StockItem(
        symbol: 'RELIANCE',
        name: 'Reliance Industries Ltd.',
        exchange: 'NSE',
        lastPrice: 2985.50,
        change: 34.20,
        changePercent: 1.16,
        open: 2955.00,
        high: 2992.00,
        low: 2950.00,
        prevClose: 2951.30,
        volume: 8450120,
        fundamentals: CompanyFundamentals(
          peRatio: 28.5,
          pbRatio: 2.4,
          marketCapCr: 2019450,
          dividendYield: 0.35,
          roe: 9.8,
          week52High: 3217.90,
          week52Low: 2220.30,
          eps: 104.75,
          sectorPE: 25.1,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 45000, totalSellQty: 38000),
        candles: generateCandles(2950.0),
      ),
      StockItem(
        symbol: 'TCS',
        name: 'Tata Consultancy Services',
        exchange: 'NSE',
        lastPrice: 4290.15,
        change: -18.40,
        changePercent: -0.43,
        open: 4312.00,
        high: 4325.00,
        low: 4280.00,
        prevClose: 4308.55,
        volume: 2154000,
        fundamentals: CompanyFundamentals(
          peRatio: 31.2,
          pbRatio: 13.5,
          marketCapCr: 1552100,
          dividendYield: 1.25,
          roe: 48.2,
          week52High: 4585.90,
          week52Low: 3400.00,
          eps: 137.50,
          sectorPE: 29.8,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 21000, totalSellQty: 29000),
        candles: generateCandles(4310.0),
      ),
      StockItem(
        symbol: 'HDFCBANK',
        name: 'HDFC Bank Ltd.',
        exchange: 'NSE',
        lastPrice: 1642.80,
        change: 14.50,
        changePercent: 0.89,
        open: 1630.00,
        high: 1648.00,
        low: 1628.00,
        prevClose: 1628.30,
        volume: 14200300,
        fundamentals: CompanyFundamentals(
          peRatio: 18.6,
          pbRatio: 2.8,
          marketCapCr: 1251900,
          dividendYield: 1.18,
          roe: 16.5,
          week52High: 1794.00,
          week52Low: 1363.55,
          eps: 88.32,
          sectorPE: 17.2,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 89000, totalSellQty: 74000),
        candles: generateCandles(1630.0),
      ),
      StockItem(
        symbol: 'INFYS',
        name: 'Infosys Ltd.',
        exchange: 'NSE',
        lastPrice: 1895.60,
        change: 22.30,
        changePercent: 1.19,
        open: 1878.00,
        high: 1902.00,
        low: 1875.00,
        prevClose: 1873.30,
        volume: 6410200,
        fundamentals: CompanyFundamentals(
          peRatio: 27.8,
          pbRatio: 8.9,
          marketCapCr: 786400,
          dividendYield: 1.95,
          roe: 31.6,
          week52High: 1994.00,
          week52Low: 1355.00,
          eps: 68.18,
          sectorPE: 29.8,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 32000, totalSellQty: 31000),
        candles: generateCandles(1875.0),
      ),
      StockItem(
        symbol: 'TATAMOTORS',
        name: 'Tata Motors Ltd.',
        exchange: 'NSE',
        lastPrice: 975.25,
        change: -8.75,
        changePercent: -0.89,
        open: 988.00,
        high: 991.00,
        low: 971.00,
        prevClose: 984.00,
        volume: 11204000,
        fundamentals: CompanyFundamentals(
          peRatio: 10.4,
          pbRatio: 3.2,
          marketCapCr: 358900,
          dividendYield: 0.61,
          roe: 30.1,
          week52High: 1179.00,
          week52Low: 605.00,
          eps: 93.77,
          sectorPE: 18.2,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 62000, totalSellQty: 79000),
        candles: generateCandles(984.0),
      ),
      StockItem(
        symbol: 'ICICIBANK',
        name: 'ICICI Bank Ltd.',
        exchange: 'NSE',
        lastPrice: 1225.40,
        change: 11.20,
        changePercent: 0.92,
        open: 1216.00,
        high: 1230.00,
        low: 1214.00,
        prevClose: 1214.20,
        volume: 9840100,
        fundamentals: CompanyFundamentals(
          peRatio: 17.5,
          pbRatio: 2.9,
          marketCapCr: 861200,
          dividendYield: 0.82,
          roe: 17.8,
          week52High: 1257.90,
          week52Low: 913.00,
          eps: 70.02,
          sectorPE: 16.5,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 48000, totalSellQty: 41000),
        candles: generateCandles(1215.0),
      ),
      StockItem(
        symbol: 'BHARTIARTL',
        name: 'Bharti Airtel Ltd.',
        exchange: 'NSE',
        lastPrice: 1540.90,
        change: 18.40,
        changePercent: 1.21,
        open: 1525.00,
        high: 1548.00,
        low: 1522.00,
        prevClose: 1522.50,
        volume: 5310000,
        fundamentals: CompanyFundamentals(
          peRatio: 72.4,
          pbRatio: 9.1,
          marketCapCr: 914000,
          dividendYield: 0.52,
          roe: 12.8,
          week52High: 1610.00,
          week52Low: 902.00,
          eps: 21.28,
          sectorPE: 45.0,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 39000, totalSellQty: 32000),
        candles: generateCandles(1525.0),
      ),
      StockItem(
        symbol: 'NIFTY 24500 CE',
        name: 'NIFTY 26 SEP 24500 Call',
        exchange: 'NFO',
        lastPrice: 142.50,
        change: 24.80,
        changePercent: 21.07,
        open: 118.00,
        high: 165.00,
        low: 105.00,
        prevClose: 117.70,
        volume: 1450200,
        openInterest: 8420050,
        isOption: true,
        fundamentals: CompanyFundamentals(
          peRatio: 0,
          pbRatio: 0,
          marketCapCr: 0,
          dividendYield: 0,
          roe: 0,
          week52High: 450.00,
          week52Low: 12.00,
          eps: 0,
          sectorPE: 0,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 180000, totalSellQty: 160000),
        candles: generateCandles(120.0),
      ),
      StockItem(
        symbol: 'NIFTY 24400 PE',
        name: 'NIFTY 26 SEP 24400 Put',
        exchange: 'NFO',
        lastPrice: 85.20,
        change: -19.40,
        changePercent: -18.55,
        open: 104.00,
        high: 110.00,
        low: 72.00,
        prevClose: 104.60,
        volume: 1890400,
        openInterest: 6150200,
        isOption: true,
        fundamentals: CompanyFundamentals(
          peRatio: 0,
          pbRatio: 0,
          marketCapCr: 0,
          dividendYield: 0,
          roe: 0,
          week52High: 380.00,
          week52Low: 8.00,
          eps: 0,
          sectorPE: 0,
        ),
        depth: MarketDepth(buyDepth: [], sellDepth: [], totalBuyQty: 140000, totalSellQty: 195000),
        candles: generateCandles(105.0),
      ),
    ]);

    // Initial selected stock
    _selectedStock = _stocks.firstWhere((s) => s.symbol == 'RELIANCE');

    // Populate Initial Depth
    for (var stock in _stocks) {
      stock.updateTick(stock.lastPrice);
    }

    // Default Holdings
    _holdings.addAll([
      HoldingItem(symbol: 'RELIANCE', name: 'Reliance Industries', quantity: 15, avgPrice: 2850.00, ltp: 2985.50, dayChange: 34.20, dayChangePercent: 1.16),
      HoldingItem(symbol: 'TCS', name: 'Tata Consultancy Services', quantity: 10, avgPrice: 4120.00, ltp: 4290.15, dayChange: -18.40, dayChangePercent: -0.43),
      HoldingItem(symbol: 'HDFCBANK', name: 'HDFC Bank Ltd.', quantity: 25, avgPrice: 1580.00, ltp: 1642.80, dayChange: 14.50, dayChangePercent: 0.89),
      HoldingItem(symbol: 'TATAMOTORS', name: 'Tata Motors', quantity: 50, avgPrice: 910.00, ltp: 975.25, dayChange: -8.75, dayChangePercent: -0.89),
    ]);

    // Default Positions
    _positions.addAll([
      PositionItem(symbol: 'NIFTY 24500 CE', product: ProductType.mis, quantity: 50, buyAvg: 128.40, sellAvg: 0.0, ltp: 142.50),
      PositionItem(symbol: 'INFYS', product: ProductType.mis, quantity: -25, buyAvg: 0.0, sellAvg: 1910.00, ltp: 1895.60),
    ]);

    // Default Orders
    _orders.addAll([
      OrderItem(
        id: 'ORD-98214',
        symbol: 'RELIANCE',
        side: OrderSide.buy,
        product: ProductType.cnc,
        type: OrderType.limit,
        quantity: 10,
        price: 2950.00,
        status: OrderStatus.executed,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      OrderItem(
        id: 'ORD-98301',
        symbol: 'TCS',
        side: OrderSide.buy,
        product: ProductType.mis,
        type: OrderType.limit,
        quantity: 5,
        price: 4250.00,
        status: OrderStatus.pending,
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      OrderItem(
        id: 'ORD-98105',
        symbol: 'NIFTY 24400 PE',
        side: OrderSide.sell,
        product: ProductType.mis,
        type: OrderType.market,
        quantity: 50,
        price: 98.50,
        status: OrderStatus.cancelled,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ]);

    // Default Alerts
    _alerts.addAll([
      PriceAlert(id: 'ALT-101', symbol: 'RELIANCE', targetPrice: 3000.00, isAbove: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
      PriceAlert(id: 'ALT-102', symbol: 'NIFTY 50', targetPrice: 24600.00, isAbove: true, createdAt: DateTime.now().subtract(const Duration(hours: 12))),
      PriceAlert(id: 'ALT-103', symbol: 'TATAMOTORS', targetPrice: 960.00, isAbove: false, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    ]);
  }

  void _startWebSocketStream() {
    _wsTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      final rand = Random();
      // Select 1 to 3 random stocks to update each tick
      int countToUpdate = rand.nextInt(3) + 1;
      for (int i = 0; i < countToUpdate; i++) {
        int idx = rand.nextInt(_stocks.length);
        var stock = _stocks[idx];

        // Small Brownian price move
        double factor = (rand.nextDouble() - 0.495);
        double delta = double.parse((stock.lastPrice * 0.0008 * factor).toStringAsFixed(2));
        if (delta == 0) delta = rand.nextBool() ? 0.05 : -0.05;
        double newPrice = max(1.0, stock.lastPrice + delta);

        stock.updateTick(newPrice);

        // Update latest candle close
        if (stock.candles.isNotEmpty) {
          var lastCandle = stock.candles.last;
          stock.candles[stock.candles.length - 1] = CandleData(
            time: lastCandle.time,
            open: lastCandle.open,
            high: max(lastCandle.high, newPrice),
            low: min(lastCandle.low, newPrice),
            close: newPrice,
            volume: lastCandle.volume + rand.nextInt(50),
          );
        }

        // Update LTP on holdings
        for (var h in _holdings) {
          if (h.symbol == stock.symbol) {
            h.ltp = stock.lastPrice;
            h.dayChange = stock.change;
            h.dayChangePercent = stock.changePercent;
          }
        }

        // Update LTP on positions
        for (var p in _positions) {
          if (p.symbol == stock.symbol) {
            p.ltp = stock.lastPrice;
          }
        }

        // Check alerts
        _checkAlerts(stock);

        _tickStreamController.add(stock);
      }
      notifyListeners();
    });
  }

  void _checkAlerts(StockItem stock) {
    for (var alert in _alerts) {
      if (alert.isActive && !alert.isTriggered && alert.symbol == stock.symbol) {
        bool hit = alert.isAbove ? (stock.lastPrice >= alert.targetPrice) : (stock.lastPrice <= alert.targetPrice);
        if (hit) {
          alert.isTriggered = true;
          alert.isActive = false;
          String msg = "ALERT TRIGGERED: ${stock.symbol} hit ₹${stock.lastPrice} (Target: ₹${alert.targetPrice})";
          notifications.insert(0, msg);
        }
      }
    }
  }

  // Trading Actions
  void placeOrder({
    required String symbol,
    required OrderSide side,
    required ProductType product,
    required OrderType type,
    required int quantity,
    required double price,
    double triggerPrice = 0.0,
  }) {
    final stock = _stocks.firstWhere((s) => s.symbol == symbol, orElse: () => _selectedStock ?? _stocks.first);
    final execPrice = (type == OrderType.market) ? stock.lastPrice : price;

    final newOrder = OrderItem(
      id: 'ORD-${Random().nextInt(89999) + 10000}',
      symbol: symbol,
      side: side,
      product: product,
      type: type,
      quantity: quantity,
      price: execPrice,
      triggerPrice: triggerPrice,
      status: (type == OrderType.market) ? OrderStatus.executed : OrderStatus.pending,
      timestamp: DateTime.now(),
      exchange: stock.exchange,
    );

    _orders.insert(0, newOrder);
    FirebaseService().syncOrder(newOrder);

    // Calculate charges according to Zerodha Pricing Rules:
    // Delivery (CNC): Brokerage ₹0
    // Intraday (MIS): ₹20 or 0.03% (whichever lower)
    double brokerage = 0.0;
    if (product == ProductType.mis || stock.isOption) {
      double pctBrokerage = execPrice * quantity * 0.0003;
      brokerage = min(20.0, pctBrokerage);
    }

    double marginRequired = execPrice * quantity;
    if (product == ProductType.mis) marginRequired = marginRequired / 5.0; // 5x leverage

    _funds.availableMargin -= (marginRequired + brokerage);
    _funds.usedMargin += marginRequired;

    // If executed immediately, update position
    if (newOrder.status == OrderStatus.executed) {
      _processExecutedOrder(newOrder);
    }

    notifications.insert(0, "Order Placed: ${side == OrderSide.buy ? 'BUY' : 'SELL'} $quantity x $symbol @ ₹${execPrice.toStringAsFixed(2)}");
    notifyListeners();
  }

  void cancelOrder(String orderId) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx].status = OrderStatus.cancelled;
      notifications.insert(0, "Order Cancelled: ${_orders[idx].id} (${_orders[idx].symbol})");
      notifyListeners();
    }
  }

  void modifyOrder(String orderId, double newPrice, int newQty) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1 && _orders[idx].status == OrderStatus.pending) {
      _orders[idx] = OrderItem(
        id: _orders[idx].id,
        symbol: _orders[idx].symbol,
        side: _orders[idx].side,
        product: _orders[idx].product,
        type: _orders[idx].type,
        quantity: newQty,
        price: newPrice,
        triggerPrice: _orders[idx].triggerPrice,
        status: OrderStatus.pending,
        timestamp: DateTime.now(),
      );
      notifications.insert(0, "Order Modified: $orderId ($newPrice)");
      notifyListeners();
    }
  }

  void _processExecutedOrder(OrderItem order) {
    final existingPosIdx = _positions.indexWhere((p) => p.symbol == order.symbol && p.product == order.product);
    if (existingPosIdx != -1) {
      var p = _positions[existingPosIdx];
      if (order.side == OrderSide.buy) {
        int newQty = p.quantity + order.quantity;
        double newAvg = (p.quantity > 0) ? ((p.buyAvg * p.quantity) + (order.price * order.quantity)) / newQty : order.price;
        _positions[existingPosIdx] = PositionItem(symbol: p.symbol, product: p.product, quantity: newQty, buyAvg: newAvg, sellAvg: p.sellAvg, ltp: order.price);
      } else {
        int newQty = p.quantity - order.quantity;
        _positions[existingPosIdx] = PositionItem(symbol: p.symbol, product: p.product, quantity: newQty, buyAvg: p.buyAvg, sellAvg: order.price, ltp: order.price);
      }
    } else {
      _positions.add(PositionItem(
        symbol: order.symbol,
        product: order.product,
        quantity: order.side == OrderSide.buy ? order.quantity : -order.quantity,
        buyAvg: order.side == OrderSide.buy ? order.price : 0.0,
        sellAvg: order.side == OrderSide.sell ? order.price : 0.0,
        ltp: order.price,
      ));
    }
  }

  void addAlert({required String symbol, required double price, required bool isAbove}) {
    final newAlert = PriceAlert(
      id: 'ALT-${Random().nextInt(899) + 100}',
      symbol: symbol,
      targetPrice: price,
      isAbove: isAbove,
      createdAt: DateTime.now(),
    );
    _alerts.add(newAlert);
    FirebaseService().syncAlert(newAlert);
    notifications.insert(0, "Alert Set: $symbol at ₹$price");
    notifyListeners();
  }

  void deleteAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
    notifyListeners();
  }

  void toggleAlert(String alertId) {
    final idx = _alerts.indexWhere((a) => a.id == alertId);
    if (idx != -1) {
      _alerts[idx].isActive = !_alerts[idx].isActive;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wsTimer?.cancel();
    _tickStreamController.close();
    super.dispose();
  }
}
