import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDesktop;
  final VoidCallback onProfileTap;
  final VoidCallback onChatTap;
  final ValueChanged<String> onSearchChanged;   // ← Mới: callback khi gõ
  final VoidCallback? onSearchSubmitted;        // ← Mới: callback khi nhấn Enter / tìm kiếm

  const HomeAppBar({
    super.key,
    required this.isDesktop,
    required this.onProfileTap,
    required this.onChatTap,
    required this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(isDesktop ? 80 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 247, 74, 74),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: isDesktop ? 80 : kToolbarHeight,
      titleSpacing: isDesktop ? 32 : 0,
      title: Row(
        children: [
          if (isDesktop) ...[
            const Icon(Icons.fastfood, color: Colors.white),
            const SizedBox(width: 8),
            const Text(
              'Food App',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 32),
          ],
          Expanded(
            child: _buildSearchBox(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: onProfileTap,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: onChatTap,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      onChanged: onSearchChanged,
      onSubmitted: (_) => onSearchSubmitted?.call(),
      decoration: InputDecoration(
        hintText: 'Tìm món ăn...',
        prefixIcon: const Icon(Icons.search, color: Colors.red),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            // Có thể thêm controller sau nếu cần clear
          },
        ),
      ),
      style: const TextStyle(fontSize: 16),
      textInputAction: TextInputAction.search,
    );
  }
}