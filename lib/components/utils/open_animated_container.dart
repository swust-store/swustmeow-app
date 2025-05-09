import 'package:flutter/cupertino.dart';

/// 修改自 [AnimatedContainer]
class OpenAnimatedContainer extends ImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  OpenAnimatedContainer(
      {super.key,
      this.alignment,
      this.padding,
      Color? color,
      Decoration? decoration,
      this.foregroundDecoration,
      double? width,
      double? height,
      BoxConstraints? constraints,
      this.margin,
      this.transform,
      this.transformAlignment,
      this.child,
      this.clipBehavior = Clip.none,
      super.curve,
      required super.duration,
      super.onEnd,
      this.onAnimation,
      this.onSize})
      : decoration =
            decoration ?? (color != null ? BoxDecoration(color: color) : null),
        constraints = (width != null || height != null)
            ? constraints?.tighten(width: width, height: height) ??
                BoxConstraints.tightFor(width: width, height: height)
            : constraints;

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Align the [child] within the container.
  ///
  /// If non-null, the container will expand to fill its parent and position its
  /// child within itself according to the given value. If the incoming
  /// constraints are unbounded, then the child will be shrink-wrapped instead.
  ///
  /// Ignored if [child] is null.
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry? alignment;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  final EdgeInsetsGeometry? padding;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration? decoration;

  /// The decoration to paint in front of the child.
  final Decoration? foregroundDecoration;

  /// Additional constraints to apply to the child.
  ///
  /// The constructor `width` and `height` arguments are combined with the
  /// `constraints` argument to set this property.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints? constraints;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The transformation matrix to apply before painting the container.
  final Matrix4? transform;

  /// The alignment of the origin, relative to the size of the container, if [transform] is specified.
  ///
  /// When [transform] is null, the value of this property is ignored.
  ///
  /// See also:
  ///
  ///  * [Transform.alignment], which is set by this property.
  final AlignmentGeometry? transformAlignment;

  /// The clip behavior when [AnimatedContainer.decoration] is not null.
  ///
  /// Defaults to [Clip.none]. Must be [Clip.none] if [decoration] is null.
  ///
  /// Unlike other properties of [AnimatedContainer], changes to this property
  /// apply immediately and have no animation.
  ///
  /// If a clip is to be applied, the [Decoration.getClipPath] method
  /// for the provided decoration must return a clip path. (This is not
  /// supported by all decorations; the default implementation of that
  /// method throws an [UnsupportedError].)
  final Clip clipBehavior;

  final Function(Animation<double>)? onAnimation;
  final Function(Size)? onSize;

  @override
  AnimatedWidgetBaseState<OpenAnimatedContainer> createState() =>
      _OpenAnimatedContainerState();
}

class _OpenAnimatedContainerState
    extends AnimatedWidgetBaseState<OpenAnimatedContainer> {
  AlignmentGeometryTween? _alignment;
  EdgeInsetsGeometryTween? _padding;
  DecorationTween? _decoration;
  DecorationTween? _foregroundDecoration;
  BoxConstraintsTween? _constraints;
  EdgeInsetsGeometryTween? _margin;
  Matrix4Tween? _transform;
  AlignmentGeometryTween? _transformAlignment;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment = visitor(
            _alignment,
            widget.alignment,
            (dynamic value) =>
                AlignmentGeometryTween(begin: value as AlignmentGeometry))
        as AlignmentGeometryTween?;
    _padding = visitor(
            _padding,
            widget.padding,
            (dynamic value) =>
                EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry))
        as EdgeInsetsGeometryTween?;
    _decoration = visitor(_decoration, widget.decoration,
            (dynamic value) => DecorationTween(begin: value as Decoration))
        as DecorationTween?;
    _foregroundDecoration = visitor(
            _foregroundDecoration,
            widget.foregroundDecoration,
            (dynamic value) => DecorationTween(begin: value as Decoration))
        as DecorationTween?;
    _constraints = visitor(
            _constraints,
            widget.constraints,
            (dynamic value) =>
                BoxConstraintsTween(begin: value as BoxConstraints))
        as BoxConstraintsTween?;
    _margin = visitor(
            _margin,
            widget.margin,
            (dynamic value) =>
                EdgeInsetsGeometryTween(begin: value as EdgeInsetsGeometry))
        as EdgeInsetsGeometryTween?;
    _transform = visitor(_transform, widget.transform,
            (dynamic value) => Matrix4Tween(begin: value as Matrix4))
        as Matrix4Tween?;
    _transformAlignment = visitor(
            _transformAlignment,
            widget.transformAlignment,
            (dynamic value) =>
                AlignmentGeometryTween(begin: value as AlignmentGeometry))
        as AlignmentGeometryTween?;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = this.animation;
    final constraints = _constraints?.evaluate(animation);
    if (widget.onAnimation != null) widget.onAnimation!(animation);
    if (widget.onSize != null && constraints != null) {
      widget.onSize!(Size(constraints.minWidth, constraints.minHeight));
    }

    return Container(
      alignment: _alignment?.evaluate(animation),
      padding: _padding?.evaluate(animation),
      decoration: _decoration?.evaluate(animation),
      foregroundDecoration: _foregroundDecoration?.evaluate(animation),
      constraints: constraints,
      margin: _margin?.evaluate(animation),
      transform: _transform?.evaluate(animation),
      transformAlignment: _transformAlignment?.evaluate(animation),
      clipBehavior: widget.clipBehavior,
      child: widget.child,
    );
  }
}
