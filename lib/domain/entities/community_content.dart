class ForumPost {
  const ForumPost({
    required this.author,
    required this.topic,
    required this.message,
    required this.timestamp,
    required this.upvotes,
  });

  final String author;
  final String topic;
  final String message;
  final DateTime timestamp;
  final int upvotes;
}

class HungerSquadAlert {
  const HungerSquadAlert({
    required this.groupName,
    required this.location,
    required this.need,
    required this.peopleImpacted,
    required this.isEmergency,
  });

  final String groupName;
  final String location;
  final String need;
  final int peopleImpacted;
  final bool isEmergency;
}

class ResourceBarter {
  const ResourceBarter({
    required this.requester,
    required this.offer,
    required this.request,
    required this.status,
  });

  final String requester;
  final String offer;
  final String request;
  final String status;
}

class FoodDriveEvent {
  const FoodDriveEvent({
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.registeredVolunteers,
  });

  final String title;
  final DateTime date;
  final String location;
  final String description;
  final int registeredVolunteers;
}

