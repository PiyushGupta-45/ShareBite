class FreshnessCheck {
  const FreshnessCheck({
    required this.label,
    required this.isMandatory,
    this.completed = false,
  });

  final String label;
  final bool isMandatory;
  final bool completed;

  FreshnessCheck toggle(bool value) =>
      FreshnessCheck(label: label, isMandatory: isMandatory, completed: value);
}

