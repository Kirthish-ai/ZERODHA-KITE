import 'dart:math';

enum OrderType { market, limit, sl, slM }
enum ProductType { mis, cnc, co, amo }
enum OrderSide { buy, sell }
enum OrderStatus { pending, executed, cancelled }

class DepthEntry {
  final double price;
  final int orders;
  final int quantity;

  DepthEntry({required this.price, required this.orders, required this.quantity});
}

class MarketDepth {
  final List<DepthEntry> buyDepth;
  final List<DepthEntry> sellDepth;
  final int totalBuyQty;
  final int totalSellQty;

  MarketDepth({
    required this.buyDepth,
    required this.sellDepth,
    required this.totalBuyQty,
    required this.totalSellQty,
  });
}

class CandleData {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  CandleData({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
}

class CompanyFundamentals {
  final double peRatio;
  final double pbRatio;
  final double marketCapCr; // In Crores
  final double dividendYield; // percentage
  final double roe; // percentage
  final double week52High;
  final double week52Low;
  final double eps;
  final double sectorPE;

  CompanyFundamentals({
    required this.peRatio,
    required this.pbRatio,
    required this.marketCapCr,
    required this.dividendYield,
    required this.roe,
    required this.week52High,
    required this.week52Low,
    required this.eps,
    required this.sectorPE,
  });
}

class StockItem {
  final String symbol;
  final String name;
  final String exchange; // NSE, BSE, NFO
  double lastPrice;
  double change;
  double changePercent;
  double open;
  double high;
  double low;
  double prevClose;
  double volume;
  double openInterest; // For F&O
  final bool isOption;
  final CompanyFundamentals fundamentals;
  MarketDepth depth;
  List<CandleData> candles;
  bool isPinned;
  DateTime lastUpdated;
  int tickDirection; // 1 for up, -1 for down, 0 for neutral

  StockItem({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.prevClose,
    required this.volume,
    this.openInterest = 0,
    this.isOption = false,
    required this.fundamentals,
    required this.depth,
    required this.candles,
    this.isPinned = false,
    DateTime? lastUpdated,
    this.tickDirection = 0,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  void updateTick(double newPrice) {
    if (newPrice > lastPrice) {
      tickDirection = 1;
    } else if (newPrice < lastPrice) {
      tickDirection = -1;
    } else {
      tickDirection = 0;
    }
    lastPrice = double.parse(newPrice.toStringAsFixed(2));
    change = double.parse((lastPrice - prevClose).toStringAsFixed(2));
    changePercent = double.parse(((change / prevClose) * 100).toStringAsFixed(2));
    if (lastPrice > high) high = lastPrice;
    if (lastPrice < low) low = lastPrice;
    volume += Random().nextInt(150) + 10;
    lastUpdated = DateTime.now();

    // Update market depth dynamically around last price
    _regenerateDepth();
  }

  void _regenerateDepth() {
    final rand = Random();
    List<DepthEntry> bids = [];
    List<DepthEntry> asks = [];
    int totB = 0;
    int totA = 0;

    for (int i = 1; i <= 5; i++) {
      double bPrice = double.parse((lastPrice - (i * 0.15 + rand.nextDouble() * 0.1)).toStringAsFixed(2));
      int bQty = (rand.nextInt(80) + 15) * 25;
      int bOrd = rand.nextInt(12) + 1;
      bids.add(DepthEntry(price: bPrice, orders: bOrd, quantity: bQty));
      totB += bQty;

      double aPrice = double.parse((lastPrice + (i * 0.15 + rand.nextDouble() * 0.1)).toStringAsFixed(2));
      int aQty = (rand.nextInt(80) + 15) * 25;
      int aOrd = rand.nextInt(12) + 1;
      asks.add(DepthEntry(price: aPrice, orders: aOrd, quantity: aQty));
      totA += aQty;
    }

    depth = MarketDepth(
      buyDepth: bids,
      sellDepth: asks,
      totalBuyQty: totB,
      totalSellQty: totA,
    );
  }
}

class OrderItem {
  final String id;
  final String symbol;
  final OrderSide side;
  final ProductType product;
  final OrderType type;
  final int quantity;
  final double price;
  final double triggerPrice;
  OrderStatus status;
  final DateTime timestamp;
  final String exchange;

  OrderItem({
    required this.id,
    required this.symbol,
    required this.side,
    required this.product,
    required this.type,
    required this.quantity,
    required this.price,
    this.triggerPrice = 0.0,
    required this.status,
    required this.timestamp,
    this.exchange = 'NSE',
  });
}

class HoldingItem {
  final String symbol;
  final String name;
  int quantity;
  double avgPrice;
  double ltp;
  double dayChange;
  double dayChangePercent;

  HoldingItem({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgPrice,
    required this.ltp,
    required this.dayChange,
    required this.dayChangePercent,
  });

  double get investedAmount => quantity * avgPrice;
  double get currentValue => quantity * ltp;
  double get totalPnL => currentValue - investedAmount;
  double get totalPnLPercent => (investedAmount > 0) ? (totalPnL / investedAmount) * 100 : 0.0;
}

class PositionItem {
  final String symbol;
  final ProductType product;
  int quantity; // positive for buy, negative for sell
  double buyAvg;
  double sellAvg;
  double ltp;

  PositionItem({
    required this.symbol,
    required this.product,
    required this.quantity,
    required this.buyAvg,
    required this.sellAvg,
    required this.ltp,
  });

  double get m2mPnL {
    if (quantity > 0) {
      return (ltp - buyAvg) * quantity;
    } else if (quantity < 0) {
      return (sellAvg - ltp) * quantity.abs();
    } else {
      return (sellAvg - buyAvg) * quantity.abs();
    }
  }
}

class PriceAlert {
  final String id;
  final String symbol;
  final double targetPrice;
  final bool isAbove; // true if trigger when price >= target, false if <= target
  bool isActive;
  final DateTime createdAt;
  bool isTriggered;

  PriceAlert({
    required this.id,
    required this.symbol,
    required this.targetPrice,
    required this.isAbove,
    this.isActive = true,
    required this.createdAt,
    this.isTriggered = false,
  });
}

class AccountFunds {
  double availableMargin;
  double usedMargin;
  double totalCollateral;
  double openingBalance;
  double payinToday;

  AccountFunds({
    required this.availableMargin,
    required this.usedMargin,
    required this.totalCollateral,
    required this.openingBalance,
    required this.payinToday,
  });
}

class UserProfile {
  final String userId;
  final String userName;
  final String email;
  final String phone;
  final String pan;
  final String avatarInitials;
  final String dematDpId;
  final String bankName;
  final String bankAccountNo;
  final bool equityActive;
  final bool foActive;
  final bool currencyActive;
  final bool commodityActive;
  final bool totpEnabled;
  final DateTime memberSince;

  UserProfile({
    required this.userId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.pan,
    required this.avatarInitials,
    required this.dematDpId,
    required this.bankName,
    required this.bankAccountNo,
    this.equityActive = true,
    this.foActive = true,
    this.currencyActive = true,
    this.commodityActive = true,
    this.totpEnabled = true,
    required this.memberSince,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'email': email,
    'phone': phone,
    'pan': pan,
    'avatarInitials': avatarInitials,
    'dematDpId': dematDpId,
    'bankName': bankName,
    'bankAccountNo': bankAccountNo,
    'equityActive': equityActive,
    'foActive': foActive,
    'currencyActive': currencyActive,
    'commodityActive': commodityActive,
    'totpEnabled': totpEnabled,
    'memberSince': memberSince.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    userId: json['userId'] ?? 'AB1234',
    userName: json['userName'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    pan: json['pan'] ?? '',
    avatarInitials: json['avatarInitials'] ?? 'ZE',
    dematDpId: json['dematDpId'] ?? '',
    bankName: json['bankName'] ?? '',
    bankAccountNo: json['bankAccountNo'] ?? '',
    equityActive: json['equityActive'] ?? true,
    foActive: json['foActive'] ?? true,
    currencyActive: json['currencyActive'] ?? true,
    commodityActive: json['commodityActive'] ?? true,
    totpEnabled: json['totpEnabled'] ?? true,
    memberSince: json['memberSince'] != null ? (DateTime.tryParse(json['memberSince']) ?? DateTime.now()) : DateTime.now(),
  );
}

