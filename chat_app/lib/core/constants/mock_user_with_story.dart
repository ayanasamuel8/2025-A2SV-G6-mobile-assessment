class Story {
  final String id;
  final String mediaUrl; // Image or video URL
  final DateTime createdAt;
  final bool isVideo;
  final bool isViewed;

  const Story({
    required this.id,
    required this.mediaUrl,
    required this.createdAt,
    this.isVideo = false,
    this.isViewed = false,
  });

  DateTime get expiresAt => createdAt.add(const Duration(hours: 24));
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class UserWithStories {
  final String id;
  final String name;
  final String displayName;
  final String avatarUrl;
  final List<Story> stories;

  const UserWithStories({
    required this.id,
    required this.name,
    required this.displayName,
    required this.avatarUrl,
    required this.stories,
  });

  bool get hasUnviewedStories =>
      stories.any((s) => !s.isViewed && !s.isExpired);

  Story? get latestStory {
    if (stories.isEmpty) return null;
    final copy = List<Story>.from(stories);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy.first;
  }
}

// Helper to create DateTimes in the past.
DateTime _hoursAgo(int h) => DateTime.now().subtract(Duration(hours: h));

// Picsum helpers for quick placeholder media
String _avatar(String seed) => 'https://picsum.photos/seed/$seed/200/200';
String _storyImage(String seed) => 'https://picsum.photos/seed/$seed/720/1280';

// Mock data: list of users with their stories.
// Use kMockUsersWithStories in your UI (e.g., story rings, story viewer).
final List<UserWithStories> kMockUsersWithStories = [
  UserWithStories(
    id: 'u1',
    name: 'nati_dev',
    displayName: 'Nati',
    avatarUrl: _avatar('nati'),
    stories: [
      Story(
        id: 'u1_s1',
        mediaUrl: _storyImage('nati-1'),
        createdAt: _hoursAgo(2),
        isViewed: false,
      ),
      Story(
        id: 'u1_s2',
        mediaUrl: _storyImage('nati-2'),
        createdAt: _hoursAgo(5),
        isViewed: true,
      ),
    ],
  ),
  UserWithStories(
    id: 'u2',
    name: 'hana_codes',
    displayName: 'Hana',
    avatarUrl: _avatar('hana'),
    stories: [
      Story(
        id: 'u2_s1',
        mediaUrl: _storyImage('hana-1'),
        createdAt: _hoursAgo(1),
        isViewed: false,
      ),
      Story(
        id: 'u2_s2',
        mediaUrl: _storyImage('hana-2'),
        createdAt: _hoursAgo(18),
        isViewed: false,
      ),
      Story(
        id: 'u2_s3',
        mediaUrl: _storyImage('hana-3'),
        createdAt: _hoursAgo(26), // likely expired
        isViewed: true,
      ),
    ],
  ),
  UserWithStories(
    id: 'u3',
    name: 'mika_ui',
    displayName: 'Mika',
    avatarUrl: _avatar('mika'),
    stories: [
      Story(
        id: 'u3_s1',
        mediaUrl: _storyImage('mika-1'),
        createdAt: _hoursAgo(10),
        isViewed: true,
      ),
    ],
  ),
  UserWithStories(
    id: 'u4',
    name: 'abel',
    displayName: 'Abel',
    avatarUrl: _avatar('abel'),
    stories: [
      Story(
        id: 'u4_s1',
        mediaUrl: _storyImage('abel-1'),
        createdAt: _hoursAgo(3),
        isViewed: false,
      ),
      Story(
        id: 'u4_s2',
        mediaUrl: _storyImage('abel-2'),
        createdAt: _hoursAgo(4),
        isViewed: false,
      ),
    ],
  ),
  UserWithStories(
    id: 'u5',
    name: 'luna',
    displayName: 'Luna',
    avatarUrl: _avatar('luna'),
    stories: [
      Story(
        id: 'u5_s1',
        mediaUrl: _storyImage('luna-1'),
        createdAt: _hoursAgo(21),
        isViewed: false,
      ),
      Story(
        id: 'u5_s2',
        mediaUrl: _storyImage('luna-2'),
        createdAt: _hoursAgo(22),
        isViewed: true,
      ),
    ],
  ),
];

// Optional: a current user with their own stories (if needed).
final UserWithStories kCurrentUserWithStories = UserWithStories(
  id: 'me',
  name: 'you',
  displayName: 'You',
  avatarUrl: _avatar('current-user'),
  stories: [
    Story(
      id: 'me_s1',
      mediaUrl: _storyImage('me-1'),
      createdAt: _hoursAgo(6),
      isViewed: true,
    ),
  ],
);
