import 'package:flutter/material.dart';

class DeliveryOption {
  final String title;
  final String? subtitle;
  final bool isSelected;

  DeliveryOption({
    required this.title,
    this.subtitle,
    this.isSelected = false,
  });
}

class DeliveryServicePage extends StatefulWidget {
  final Function(DeliveryOption)? onDeliverySelected;

  const DeliveryServicePage({
    Key? key,
    this.onDeliverySelected,
  }) : super(key: key);

  @override
  State<DeliveryServicePage> createState() => _DeliveryServicePageState();
}

class _DeliveryServicePageState extends State<DeliveryServicePage> {
  int _selectedShippingMethod = 0; // 0: 顺丰速运, 1: 退货包邮运费
  int _selectedPickupPoint = 0; // 0: 送货上门, 1: 驿站自提, 2: 快递站

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 顶部提示
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: Colors.grey[100],
          child: const Text(
            '配送公司、运费和收货地址不同，可能产生差异，部分支持指定配送，最终确认收货地址后收取运费。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),

        // 发货信息
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              const Text(
                '苏州市发出，在发货后承诺送达日期',
                style: TextStyle(fontSize: 14),
              ),
              const Spacer(),
              Text(
                '详细规则',
                style: TextStyle(fontSize: 14, color: Colors.teal[400]),
              ),
              Icon(Icons.chevron_right, size: 16, color: Colors.teal[400]),
            ],
          ),
        ),

        const Divider(height: 1),

        // 配送方式 - 顺丰速运
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<int>(
            value: 0,
            groupValue: _selectedShippingMethod,
            onChanged: (value) {
              setState(() {
                _selectedShippingMethod = value!;
              });
            },
            activeColor: const Color(0xFF00C1B3),
          ),
          title: const Row(
            children: [
              Text('顺丰速运', style: TextStyle(fontSize: 15)),
              SizedBox(width: 8),
              Text('包邮', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          trailing: const Text('自邮', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),

        const Divider(height: 1),

        // 配送方式 - 退货包邮运费
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<int>(
            value: 1,
            groupValue: _selectedShippingMethod,
            onChanged: (value) {
              setState(() {
                _selectedShippingMethod = value!;
              });
            },
            activeColor: const Color(0xFF00C1B3),
          ),
          title: const Row(
            children: [
              Text('退货包邮运费', style: TextStyle(fontSize: 15)),
            ],
          ),
          trailing: const Text('平台配送', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),

        const Divider(height: 1),

        // 收件地点标题
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Text('收件地点', style: TextStyle(fontSize: 14)),
              const Spacer(),
              Text('详细规则', style: TextStyle(fontSize: 14, color: Colors.teal[400])),
              Icon(Icons.chevron_right, size: 16, color: Colors.teal[400]),
            ],
          ),
        ),

        // 收件地点 - 送货上门
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<int>(
            value: 0,
            groupValue: _selectedPickupPoint,
            onChanged: (value) {
              setState(() {
                _selectedPickupPoint = value!;
              });
            },
            activeColor: const Color(0xFF00C1B3),
          ),
          title: const Row(
            children: [
              Text('送货上门（可打电话）', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),

        const Divider(height: 1),

        // 收件地点 - 驿站自提
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<int>(
            value: 1,
            groupValue: _selectedPickupPoint,
            onChanged: (value) {
              setState(() {
                _selectedPickupPoint = value!;
              });
            },
            activeColor: const Color(0xFF00C1B3),
          ),
          title: const Row(
            children: [
              Text('驿站至快递柜', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),

        const Divider(height: 1),

        // 收件地点 - 快递站
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Radio<int>(
            value: 2,
            groupValue: _selectedPickupPoint,
            onChanged: (value) {
              setState(() {
                _selectedPickupPoint = value!;
              });
            },
            activeColor: const Color(0xFF00C1B3),
          ),
          title: const Row(
            children: [
              Text('驿站至快递站', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),

        const Divider(height: 1),

        // 底部确认按钮
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              final selectedDelivery = DeliveryOption(
                title: _selectedShippingMethod == 0 ? '顺丰速运' : '退货包邮运费',
                subtitle: _getPickupPointText(),
                isSelected: true,
              );
              
              if (widget.onDeliverySelected != null) {
                widget.onDeliverySelected!(selectedDelivery);
              }
              
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C1B3),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('确定', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  String _getPickupPointText() {
    switch (_selectedPickupPoint) {
      case 0:
        return '送货上门（可打电话）';
      case 1:
        return '驿站至快递柜';
      case 2:
        return '驿站至快递站';
      default:
        return '送货上门';
    }
  }
} 