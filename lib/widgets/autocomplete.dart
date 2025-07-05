import 'package:flutter/material.dart';

class CustomAutocomplete extends StatefulWidget {
  final List<String> suggestions;
  final String labelText;
  final String hintText;
  final void Function(String)? onSelected;
  final void Function()? onCleared;

  const CustomAutocomplete({
    super.key,
    required this.suggestions,
    this.labelText = 'Search',
    this.hintText = 'Type to search',
    this.onSelected,
    this.onCleared,
  });

  @override
  State<CustomAutocomplete> createState() => _CustomAutocompleteState();
}

class _CustomAutocompleteState extends State<CustomAutocomplete> {
  final GlobalKey _fieldKey = GlobalKey();
  FocusNode? _currentFocusNode;

  @override
  void dispose() {
    _currentFocusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (_currentFocusNode?.hasFocus ?? false) {
      _scrollToField();
    }
  }

  void _scrollToField() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final scrollableState = Scrollable.maybeOf(context);

        if (scrollableState != null) {
          // Calculate the target scroll position to bring field to top
          final targetScrollOffset =
              scrollableState.position.pixels + position.dy - 150;

          scrollableState.position.animateTo(
            targetScrollOffset.clamp(
              scrollableState.position.minScrollExtent,
              scrollableState.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 4),
          child: Text(
            widget.labelText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xff16425B),
            ),
          ),
        ),
        Container(
          key: _fieldKey,
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              // Show all suggestions when field is empty or just focused
              if (textEditingValue.text.isEmpty) {
                return widget.suggestions;
              }
              return widget.suggestions.where((String option) {
                return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
              });
            },
            onSelected: widget.onSelected,
            fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted,
            ) {
              // Set up focus listener for auto-scroll
              if (_currentFocusNode != focusNode) {
                _currentFocusNode?.removeListener(_onFocusChange);
                _currentFocusNode = focusNode;
                _currentFocusNode?.addListener(_onFocusChange);
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: const Color(0xffd9dcd6),
                ),
                child: TextField(
                  style: const TextStyle(color: Color(0xff16425B)),
                  controller: textEditingController,
                  focusNode: focusNode,
                  cursorColor: const Color(0xff16425B),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(color: Color(0xff85756E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide:
                          const BorderSide(color: Colors.red, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color(0xff16425B),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color(0xff16425B),
                        width: 2,
                      ),
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: textEditingController,
                      builder: (context, value, child) {
                        return value.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xff16425B),
                                ),
                                onPressed: () {
                                  textEditingController.clear();
                                  // Call the onCleared callback to reset the variable
                                  if (widget.onCleared != null) {
                                    widget.onCleared!();
                                  }
                                },
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                ),
              );
            },
            optionsViewBuilder: (
              BuildContext context,
              AutocompleteOnSelected<String> onSelected,
              Iterable<String> options,
            ) {
              // Get screen height and keyboard height
              final mediaQuery = MediaQuery.of(context);
              final screenHeight = mediaQuery.size.height;
              final keyboardHeight = mediaQuery.viewInsets.bottom;
              final availableHeight = screenHeight - keyboardHeight;

              // Calculate maximum height for options list
              final maxOptionsHeight =
                  (availableHeight * 0.4).clamp(150.0, 300.0);

              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: maxOptionsHeight,
                      maxWidth:
                          mediaQuery.size.width - 32, // Account for padding
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffd9dcd6),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xff16425B),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: options.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No options found',
                              style: TextStyle(
                                color: Color(0xff85756E),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(8.0),
                            shrinkWrap: true,
                            itemCount: options.length,
                            separatorBuilder: (context, index) => const Divider(
                              height: 1,
                              color: Color(0xff85756E),
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return InkWell(
                                borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      color: Color(0xff16425B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
