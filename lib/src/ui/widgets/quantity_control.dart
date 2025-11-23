import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class QuantityControl extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final Color? backgroundColor;
  final Color? textColor;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  bool _isExpanded = false;
  Timer? _collapseTimer;

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void _startCollapseTimer() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _startCollapseTimer();
    } else {
      _collapseTimer?.cancel();
    }
  }

  void _close() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
      _collapseTimer?.cancel();
    }
  }

  void _increment() {
    widget.onChanged(widget.quantity + 1);
    _startCollapseTimer();
  }

  void _decrement() {
    if (widget.quantity > 1) {
      widget.onChanged(widget.quantity - 1);
      _startCollapseTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _close(),
      child: GestureDetector(
        onTap: _toggleExpand,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[
                _buildButton(
                  icon: Icons.remove,
                  onTap: _decrement,
                  enabled: widget.quantity > 1,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _isExpanded ? '${widget.quantity}' : 'x${widget.quantity}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor ?? Colors.black,
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(width: 8),
                _buildButton(
                  icon: Icons.add,
                  onTap: _increment,
                  enabled: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: enabled 
              ? (isDark ? Colors.grey[600] : Colors.white) 
              : (isDark ? Colors.grey[800] : Colors.grey[300]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled 
              ? (isDark ? Colors.white : Colors.black) 
              : (isDark ? Colors.grey[600] : Colors.grey[500]),
        ),
      ),
    );
  }
}
