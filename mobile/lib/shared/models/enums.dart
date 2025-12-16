/// Trip Item Type enum
enum TripItemType {
  transport,
  stay,
  activity,
  note;

  String get displayName {
    switch (this) {
      case TripItemType.transport:
        return 'Transport';
      case TripItemType.stay:
        return 'Stay';
      case TripItemType.activity:
        return 'Activity';
      case TripItemType.note:
        return 'Note';
    }
  }

  String get icon {
    switch (this) {
      case TripItemType.transport:
        return '✈️';
      case TripItemType.stay:
        return '🏨';
      case TripItemType.activity:
        return '🎟️';
      case TripItemType.note:
        return '📝';
    }
  }
}

/// Transport Mode enum
enum TransportMode {
  flight,
  train,
  bus,
  car,
  bike,
  cruise,
  metro,
  ferry,
  other;

  String get displayName {
    switch (this) {
      case TransportMode.flight:
        return 'Flight';
      case TransportMode.train:
        return 'Train';
      case TransportMode.bus:
        return 'Bus';
      case TransportMode.car:
        return 'Car';
      case TransportMode.bike:
        return 'Bike';
      case TransportMode.cruise:
        return 'Cruise';
      case TransportMode.metro:
        return 'Metro';
      case TransportMode.ferry:
        return 'Ferry';
      case TransportMode.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case TransportMode.flight:
        return '✈️';
      case TransportMode.train:
        return '🚂';
      case TransportMode.bus:
        return '🚌';
      case TransportMode.car:
        return '🚗';
      case TransportMode.bike:
        return '🚲';
      case TransportMode.cruise:
        return '🚢';
      case TransportMode.metro:
        return '🚇';
      case TransportMode.ferry:
        return '⛴️';
      case TransportMode.other:
        return '🚙';
    }
  }
}

/// Document Type enum
enum DocumentType {
  passport,
  visa,
  insurance,
  ticket,
  hotelVoucher,
  activityVoucher,
  other;

  String get displayName {
    switch (this) {
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.visa:
        return 'Visa';
      case DocumentType.insurance:
        return 'Travel Insurance';
      case DocumentType.ticket:
        return 'Ticket';
      case DocumentType.hotelVoucher:
        return 'Hotel Voucher';
      case DocumentType.activityVoucher:
        return 'Activity Voucher';
      case DocumentType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case DocumentType.passport:
        return '🛂';
      case DocumentType.visa:
        return '📜';
      case DocumentType.insurance:
        return '🛡️';
      case DocumentType.ticket:
        return '🎫';
      case DocumentType.hotelVoucher:
        return '📎';
      case DocumentType.activityVoucher:
        return '🎟️';
      case DocumentType.other:
        return '📁';
    }
  }
}

/// Activity Category
enum ActivityCategory {
  tour,
  museum,
  food,
  nightlife,
  adventure,
  shopping,
  relaxation,
  other;

  String get displayName {
    switch (this) {
      case ActivityCategory.tour:
        return 'Tour';
      case ActivityCategory.museum:
        return 'Museum';
      case ActivityCategory.food:
        return 'Food';
      case ActivityCategory.nightlife:
        return 'Nightlife';
      case ActivityCategory.adventure:
        return 'Adventure';
      case ActivityCategory.shopping:
        return 'Shopping';
      case ActivityCategory.relaxation:
        return 'Relaxation';
      case ActivityCategory.other:
        return 'Other';
    }
  }
}

/// Checklist Category enum
enum ChecklistCategory {
  packing,
  shopping,
  documents,
  food,
  health,
  bookings,
  transport,
  custom;

  String get displayName {
    switch (this) {
      case ChecklistCategory.packing:
        return 'Packing';
      case ChecklistCategory.shopping:
        return 'Shopping';
      case ChecklistCategory.documents:
        return 'Documents';
      case ChecklistCategory.food:
        return 'Food';
      case ChecklistCategory.health:
        return 'Health';
      case ChecklistCategory.bookings:
        return 'Bookings';
      case ChecklistCategory.transport:
        return 'Transport';
      case ChecklistCategory.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case ChecklistCategory.packing:
        return '📦';
      case ChecklistCategory.shopping:
        return '🛒';
      case ChecklistCategory.documents:
        return '📄';
      case ChecklistCategory.food:
        return '🍽️';
      case ChecklistCategory.health:
        return '💊';
      case ChecklistCategory.bookings:
        return '🎫';
      case ChecklistCategory.transport:
        return '🚗';
      case ChecklistCategory.custom:
        return '📝';
    }
  }
}

/// Checklist Phase enum
enum ChecklistPhase {
  beforeTrip,
  duringTrip,
  afterTrip;

  String get displayName {
    switch (this) {
      case ChecklistPhase.beforeTrip:
        return 'Before Trip';
      case ChecklistPhase.duringTrip:
        return 'During Trip';
      case ChecklistPhase.afterTrip:
        return 'After Trip';
    }
  }

  String get icon {
    switch (this) {
      case ChecklistPhase.beforeTrip:
        return '📋';
      case ChecklistPhase.duringTrip:
        return '✈️';
      case ChecklistPhase.afterTrip:
        return '🏠';
    }
  }
}

/// Trip Status enum
enum TripStatus {
  planned,
  active,
  completed;

  String get displayName {
    switch (this) {
      case TripStatus.planned:
        return 'Planned';
      case TripStatus.active:
        return 'Active';
      case TripStatus.completed:
        return 'Completed';
    }
  }

  String get icon {
    switch (this) {
      case TripStatus.planned:
        return '📋';
      case TripStatus.active:
        return '✈️';
      case TripStatus.completed:
        return '✅';
    }
  }

  static TripStatus fromString(String? value) {
    switch (value) {
      case 'active':
        return TripStatus.active;
      case 'completed':
        return TripStatus.completed;
      default:
        return TripStatus.planned;
    }
  }

  String toDbString() {
    switch (this) {
      case TripStatus.planned:
        return 'planned';
      case TripStatus.active:
        return 'active';
      case TripStatus.completed:
        return 'completed';
    }
  }
}

/// Payment Status enum for expense tracking
enum PaymentStatus {
  notPaid,
  paid,
  partial;

  String get displayName {
    switch (this) {
      case PaymentStatus.notPaid:
        return 'Not Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partial:
        return 'Partially Paid';
    }
  }

  String get icon {
    switch (this) {
      case PaymentStatus.notPaid:
        return '⏳';
      case PaymentStatus.paid:
        return '✅';
      case PaymentStatus.partial:
        return '⚠️';
    }
  }

  static PaymentStatus fromString(String? value) {
    switch (value) {
      case 'paid':
        return PaymentStatus.paid;
      case 'partial':
        return PaymentStatus.partial;
      default:
        return PaymentStatus.notPaid;
    }
  }

  String toDbString() {
    switch (this) {
      case PaymentStatus.notPaid:
        return 'not_paid';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.partial:
        return 'partial';
    }
  }
}

/// Expense Category enum for categorizing trip expenses
enum ExpenseCategory {
  transport,
  stay,
  activity,
  food,
  shopping,
  other;

  String get displayName {
    switch (this) {
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.stay:
        return 'Accommodation';
      case ExpenseCategory.activity:
        return 'Activities';
      case ExpenseCategory.food:
        return 'Food & Dining';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.transport:
        return '✈️';
      case ExpenseCategory.stay:
        return '🏨';
      case ExpenseCategory.activity:
        return '🎟️';
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.other:
        return '📦';
    }
  }

  static ExpenseCategory fromString(String? value) {
    switch (value) {
      case 'transport':
        return ExpenseCategory.transport;
      case 'stay':
        return ExpenseCategory.stay;
      case 'activity':
        return ExpenseCategory.activity;
      case 'food':
        return ExpenseCategory.food;
      case 'shopping':
        return ExpenseCategory.shopping;
      default:
        return ExpenseCategory.other;
    }
  }
}

/// Global Document Type enum for user-level travel documents
enum GlobalDocumentType {
  passport,
  visa,
  travelInsurance,
  healthCard,
  idCard,
  vaccinationCertificate,
  other;

  String get displayName {
    switch (this) {
      case GlobalDocumentType.passport:
        return 'Passport';
      case GlobalDocumentType.visa:
        return 'Visa';
      case GlobalDocumentType.travelInsurance:
        return 'Travel Insurance';
      case GlobalDocumentType.healthCard:
        return 'Health Card';
      case GlobalDocumentType.idCard:
        return 'ID Card';
      case GlobalDocumentType.vaccinationCertificate:
        return 'Vaccination Certificate';
      case GlobalDocumentType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case GlobalDocumentType.passport:
        return '🛂';
      case GlobalDocumentType.visa:
        return '📜';
      case GlobalDocumentType.travelInsurance:
        return '🛡️';
      case GlobalDocumentType.healthCard:
        return '💊';
      case GlobalDocumentType.idCard:
        return '🪪';
      case GlobalDocumentType.vaccinationCertificate:
        return '💉';
      case GlobalDocumentType.other:
        return '📁';
    }
  }

  static GlobalDocumentType fromString(String? value) {
    switch (value) {
      case 'passport':
        return GlobalDocumentType.passport;
      case 'visa':
        return GlobalDocumentType.visa;
      case 'travel_insurance':
        return GlobalDocumentType.travelInsurance;
      case 'health_card':
        return GlobalDocumentType.healthCard;
      case 'id_card':
        return GlobalDocumentType.idCard;
      case 'vaccination_certificate':
        return GlobalDocumentType.vaccinationCertificate;
      default:
        return GlobalDocumentType.other;
    }
  }

  String toDbString() {
    switch (this) {
      case GlobalDocumentType.passport:
        return 'passport';
      case GlobalDocumentType.visa:
        return 'visa';
      case GlobalDocumentType.travelInsurance:
        return 'travel_insurance';
      case GlobalDocumentType.healthCard:
        return 'health_card';
      case GlobalDocumentType.idCard:
        return 'id_card';
      case GlobalDocumentType.vaccinationCertificate:
        return 'vaccination_certificate';
      case GlobalDocumentType.other:
        return 'other';
    }
  }
}
