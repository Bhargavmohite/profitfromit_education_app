import 'package:flutter/material.dart';
import 'package:webinar/app/widgets/authentication_widget/auth_design.dart';

class AuthWidget {
  static Widget accountTypeWidget(
      String title, String selectedType, String type, Function onTap) {
    final bool selected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 43,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AuthDesign.navy : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: AuthDesign.navy.withValues(alpha: .13),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ]
                  : [],
            ),
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AuthDesign.muted)),
          ),
        ),
      ),
    );
  }
}
