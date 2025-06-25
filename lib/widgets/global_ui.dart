import 'package:flutter/material.dart';
import 'package:grsfApp/models/global.dart';

Widget dataDisplay({required String label, required String value}) {
  if (value.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xff16425B),
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  } else {
    return const SizedBox.shrink();
  }
}

Widget dataDetailsDisplay(
    {required String label,
    required String code,
    required String system,
    required String name,
    required bool withIcon,
    VoidCallback? onIconPressed,
    IconData? icon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff16425B),
          fontWeight: FontWeight.normal,
        ),
      ),
      if (code.isNotEmpty)
        Text(
          'Code     : $code',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
      if (system.isNotEmpty)
        Text(
          'System : $system',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xff16425B),
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
          maxLines: null,
        ),
      if (name.isNotEmpty)
        Row(
          children: [
            Text(
              'Name    : $name',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xff16425B),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
              maxLines: null,
            ),
            const Spacer(),
            if (withIcon)
              InkWell(
                onTap: onIconPressed,
                child: Icon(
                  icon,
                  color: const Color(0xff16425B),
                  size: 25,
                ),
              ),
          ],
        ),
      const SizedBox(
        height: 5,
      )
    ],
  );
}

Widget customButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff16425B), // Dynamic background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded edges
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 8), // Dynamic padding
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xffd9dcd6), // Dynamic text color
      ),
    ),
  );
}

Align statusDisplay(String status) {
  return Align(
    alignment: Alignment.centerRight,
    child: Text(
      status,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: getColor(status),
      ),
    ),
  );
}

Widget iconButton({
  required VoidCallback onPressed,
  required IconData icon,
}) {
  return IconButton(
    onPressed: onPressed,
    icon: Icon(
      icon,
      color: const Color(0xff16425B),
      size: 24,
    ),
    splashRadius: 24,
  );
}
