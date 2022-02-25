import 'package:flutter/material.dart';

class RadiusSlider extends StatefulWidget {
  final Function(double)? onCallBack;
  final Function? moveToCurrentPos;
  final double? minRadius;
  final double? maxRadius;
  final double? currentVal;

  const RadiusSlider(
      {Key? key,
      this.onCallBack,
      this.minRadius,
      this.maxRadius,
      this.currentVal,
      this.moveToCurrentPos})
      : super(key: key);
  @override
  _RadiusSliderState createState() => _RadiusSliderState();
}

class _RadiusSliderState extends State<RadiusSlider> {
  double? currentVal;

  @override
  void initState() {
    currentVal = widget.currentVal;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 50.0,
      height: 40,
      margin: const EdgeInsets.only(top: 20.0, left: 40.0, right: 20.0),
      child: Row(
        children: [
          Flexible(
            child: Slider(
              max: widget.maxRadius!,
              min: widget.minRadius!,
              onChanged: (double value) {
                currentVal = value;
                widget.onCallBack!(value);
              },
              value: currentVal!,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Colors.grey.withOpacity(0.6)),
            child: Text(
              '${currentVal!.toStringAsFixed(2)} km',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white, fontFamily: 'Roboto'),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: widget.moveToCurrentPos as void Function()?,
            child: const Icon(
              Icons.my_location_outlined,
              color: Colors.grey,
              size: 36.0,
            ),
          ),
        ],
      ),
    );
  }
}
