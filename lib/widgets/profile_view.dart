import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/stock_model.dart';
import '../services/trading_service.dart';

class ProfileView extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileView({super.key, required this.onLogout});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String _chartEngine = 'TradingView';
  String _defaultProduct = 'MIS Intraday';

  @override
  Widget build(BuildContext context) {
    final service = TradingService();
    final profile = service.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 500;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Title Banner
              if (isMobile) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('User Profile & Settings', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Manage your account details, demat settings, security, and app preferences.', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      service.logout();
                      widget.onLogout();
                    },
                    icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                    label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KiteTheme.red,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('User Profile & Settings', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Manage your account details, demat settings, security, and app preferences.', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
                      ],
                    ),

                    // Logout Button
                    ElevatedButton.icon(
                      onPressed: () {
                        service.logout();
                        widget.onLogout();
                      },
                      icon: const Icon(Icons.logout, size: 16, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KiteTheme.red,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // User Profile Main Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: KiteTheme.panelBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: KiteTheme.border),
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: KiteTheme.zerodhaOrange,
                                child: Text(
                                  profile.avatarInitials,
                                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.userName,
                                      style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: KiteTheme.kiteBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: KiteTheme.kiteBlue.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        'CLIENT ID: ${profile.userId}',
                                        style: const TextStyle(color: KiteTheme.kiteBlue, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_outlined, size: 14, color: KiteTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Flexible(child: Text(profile.email, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 14, color: KiteTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(profile.phone, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Member Since: ', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
                              Text(
                                '${profile.memberSince.day}/${profile.memberSince.month}/${profile.memberSince.year}',
                                style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: KiteTheme.zerodhaOrange,
                            child: Text(
                              profile.avatarInitials,
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      profile.userName,
                                      style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: KiteTheme.kiteBlue.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: KiteTheme.kiteBlue.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        'CLIENT ID: ${profile.userId}',
                                        style: const TextStyle(color: KiteTheme.kiteBlue, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: KiteTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(profile.email, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.phone_outlined, size: 14, color: KiteTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(profile.phone, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Member Since', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${profile.memberSince.day}/${profile.memberSince.month}/${profile.memberSince.year}',
                                style: const TextStyle(color: KiteTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

              // Active Segments & Trading Permissions
              const Text('TRADING SEGMENTS & PERMISSIONS', style: TextStyle(color: KiteTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildSegmentBadge('Equity (NSE/BSE)', profile.equityActive),
                  _buildSegmentBadge('Futures & Options (NFO)', profile.foActive),
                  _buildSegmentBadge('Currency (CDS)', profile.currencyActive),
                  _buildSegmentBadge('Commodity (MCX)', profile.commodityActive),
                  _buildSegmentBadge('Mutual Funds (Direct)', true),
                ],
              ),

              const SizedBox(height: 24),

              // Grid Section: Personal/Demat Details & Security/Preferences
              if (isMobile) ...[
                // Mobile: Stack vertically
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: KiteTheme.panelBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KiteTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.account_balance, color: KiteTheme.kiteBlue, size: 18),
                          SizedBox(width: 8),
                          Flexible(child: Text('Personal & Demat Account', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const Divider(height: 20, color: KiteTheme.border),
                      _buildProfileDetailRow('PAN Number', profile.pan),
                      _buildProfileDetailRow('Demat DP ID (CDSL)', profile.dematDpId),
                      _buildProfileDetailRow('Primary Bank', profile.bankName),
                      _buildProfileDetailRow('Account Number', profile.bankAccountNo),
                      _buildProfileDetailRow('Depository Participant', 'Zerodha Broking Ltd.'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: KiteTheme.panelBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KiteTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.shield_outlined, color: KiteTheme.zerodhaOrange, size: 18),
                          SizedBox(width: 8),
                          Flexible(child: Text('Security & App Preferences', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      const Divider(height: 20, color: KiteTheme.border),

                      _buildProfileDetailRow('Two-Factor Auth (TOTP)', profile.totpEnabled ? 'ENABLED (App Authenticator)' : 'DISABLED'),
                      _buildProfileDetailRow('App Security PIN', 'Active (6-digit)'),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(child: Text('Charting Engine', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13))),
                          DropdownButton<String>(
                            value: _chartEngine,
                            dropdownColor: KiteTheme.panelBg,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'TradingView', child: Text('TradingView v2.0')),
                              DropdownMenuItem(value: 'ChartIQ', child: Text('ChartIQ 8.0')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _chartEngine = val);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(child: Text('Default Order Product', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13))),
                          DropdownButton<String>(
                            value: _defaultProduct,
                            dropdownColor: KiteTheme.panelBg,
                            style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'MIS Intraday', child: Text('MIS (Intraday)')),
                              DropdownMenuItem(value: 'CNC Longterm', child: Text('CNC (Longterm)')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _defaultProduct = val);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Demat & Bank Details
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: KiteTheme.panelBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KiteTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.account_balance, color: KiteTheme.kiteBlue, size: 18),
                                SizedBox(width: 8),
                                Text('Personal & Demat Account', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 20, color: KiteTheme.border),
                            _buildProfileDetailRow('PAN Number', profile.pan),
                            _buildProfileDetailRow('Demat DP ID (CDSL)', profile.dematDpId),
                            _buildProfileDetailRow('Primary Bank', profile.bankName),
                            _buildProfileDetailRow('Account Number', profile.bankAccountNo),
                            _buildProfileDetailRow('Depository Participant', 'Zerodha Broking Ltd.'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Column 2: Security & App Preferences
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: KiteTheme.panelBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: KiteTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.shield_outlined, color: KiteTheme.zerodhaOrange, size: 18),
                                SizedBox(width: 8),
                                Text('Security & App Preferences', style: TextStyle(color: KiteTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 20, color: KiteTheme.border),

                            _buildProfileDetailRow('Two-Factor Auth (TOTP)', profile.totpEnabled ? 'ENABLED (App Authenticator)' : 'DISABLED'),
                            _buildProfileDetailRow('App Security PIN', 'Active (6-digit)'),

                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Charting Engine', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
                                DropdownButton<String>(
                                  value: _chartEngine,
                                  dropdownColor: KiteTheme.panelBg,
                                  style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(value: 'TradingView', child: Text('TradingView v2.0')),
                                    DropdownMenuItem(value: 'ChartIQ', child: Text('ChartIQ 8.0')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _chartEngine = val);
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Default Order Product', style: TextStyle(color: KiteTheme.textSecondary, fontSize: 13)),
                                DropdownButton<String>(
                                  value: _defaultProduct,
                                  dropdownColor: KiteTheme.panelBg,
                                  style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold),
                                  underline: const SizedBox(),
                                  items: const [
                                    DropdownMenuItem(value: 'MIS Intraday', child: Text('MIS (Intraday)')),
                                    DropdownMenuItem(value: 'CNC Longterm', child: Text('CNC (Longterm)')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setState(() => _defaultProduct = val);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSegmentBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? KiteTheme.greenBg : KiteTheme.darkBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isActive ? KiteTheme.green.withOpacity(0.5) : KiteTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Icons.check_circle : Icons.cancel, size: 14, color: isActive ? KiteTheme.green : KiteTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? KiteTheme.green : KiteTheme.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(title, style: const TextStyle(color: KiteTheme.textSecondary, fontSize: 13))),
          const SizedBox(width: 8),
          Flexible(child: Text(value, style: const TextStyle(color: KiteTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
