import 'package:deliverit_driver/models/payload.dart';

class DataPayload {
  static final all = <Payload>[
    Payload(name: 'Kardus', size: PayloadSize.small, qty: 1),
    Payload(name: 'Kardus', size: PayloadSize.medium, qty: 1),
    Payload(name: 'Kardus', size: PayloadSize.large, qty: 1),
    Payload(name: 'Kasur', size: PayloadSize.medium, qty: 1),
    Payload(name: 'Kasur', size: PayloadSize.large, qty: 1),
    Payload(name: 'Meja', size: PayloadSize.medium, qty: 1),
    Payload(name: 'Meja', size: PayloadSize.large, qty: 1),
    Payload(name: 'Lemari', size: PayloadSize.medium, qty: 1),
    Payload(name: 'Lemari', size: PayloadSize.large, qty: 1),
    Payload(name: 'Koper', size: PayloadSize.small, qty: 1),
    Payload(name: 'Koper', size: PayloadSize.medium, qty: 1),
    Payload(name: 'Koper', size: PayloadSize.large, qty: 1),
  ];
}
