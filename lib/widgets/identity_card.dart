import 'package:flutter/material.dart';
import 'package:grsfApp/global.dart';
import 'package:grsfApp/widgets/global_ui.dart';

class IdentityCard extends StatefulWidget {
  final String name, id, title, uuid, type, status;
  final String? url;
  final bool map;
  const IdentityCard(
      {super.key,
      required this.name,
      required this.id,
      required this.title,
      required this.uuid,
      required this.type,
      required this.status,
      this.url,
      this.map = false});

  @override
  State<IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends State<IdentityCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffd9dcd6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          statusDisplay(widget.status),
          dataDisplay(label: 'Short Name', value: widget.name),
          dataDisplay(label: 'Semantic ID', value: widget.id),
          dataDisplay(label: 'Semantic Title', value: widget.title),
          dataDisplay(label: 'UUID', value: widget.uuid),
          dataDisplay(label: 'Type', value: widget.type),
          Row(
            children: [
              if (widget.map)
                Align(
                  alignment: Alignment.centerLeft,
                  child: iButton(
                      icon: Icons.map_outlined,
                      onPressed: () =>
                          showMap(context, 'Stock Map', widget.uuid),
                      assetPath: '',
                      iconSize: 24),
                ),
              Spacer(),
              if (widget.url != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: iButton(
                      icon: Icons.link,
                      onPressed: () => openSourceLink(widget.url ?? ''),
                      assetPath: '',
                      iconSize: 24),
                ),
            ],
          )
        ],
      ),
    );
  }
}
