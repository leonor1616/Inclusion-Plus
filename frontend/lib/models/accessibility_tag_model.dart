class AccessibilityTagModel {
  final String name;
  final String label;
  final String? iconAsset;

  const AccessibilityTagModel({
    required this.name,
    required this.label,
    this.iconAsset,
  });
}