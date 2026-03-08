// Notifications
const notificationChannelKey = 'mytube_downloads_channel';
const notificationChannelName = 'Downloads Channel';
const notificationChannelDescription = 'Shows the progress of downloads';

// Defaults
const String defaultCountryCode = 'US';

// Hive box names
const String hiveSettingsBoxName = 'settings';
const String hiveFavoriteVideosBoxName = 'favoriteVideos';
const String hiveFavoriteChannelsBoxName = 'favoriteChannels';
const String hiveFavoritePlaylistsBoxName = 'favoritePlaylists';
const String hiveRecentlyPlayedBoxName = 'recentlyPlayed';

// Settings keys
const String settingsCountryCodeKey = 'countryCode';
const String settingsThemeSettingsKey = 'themeSettings';
const String settingsQueryHistoryKey = 'queryHistory';
const String settingsMusicDiscoverSeedKey = 'musicDiscoverSeedIndex';

// Generic limits
const int searchHistoryMaxItems = 15;
const int recentlyPlayedMaxStored = 30;
const int recentlyPlayedMaxReturned = 20;

// Music tab limits
const Duration discoverMinDuration = Duration(seconds: 90);
const Duration discoverMaxDuration = Duration(minutes: 15);
const Duration newReleasesMinDuration = Duration(seconds: 61);
const int newReleasesMaxPerChannel = 2;
const int newReleasesMaxTotal = 20;

// Update API and APK naming
const String githubApiAcceptHeaderKey = 'Accept';
const String githubApiAcceptHeaderValue = 'application/vnd.github.+json';
const String githubLatestReleaseApiUrl =
    'https://api.github.com/repos/gmstyle/my_tube/releases/latest';
const String githubReleaseDownloadUrlPrefix =
    'https://github.com/gmstyle/my_tube/releases/download';
const String releaseApkFilePrefix = 'app-release-';
const String releaseApkFileExtension = '.apk';

// Shared UI labels
const String globalSearchFieldLabel = 'Search videos, channels, playlists...';
const String sectionSeeAllLabel = 'See all';
const String actionCancelLabel = 'Cancel';
const String actionCloseLabel = 'Close';
const String actionCheckLabel = 'Check';

// Settings UI copy
const String settingsLatestVersionMessage = 'You are on the latest version';
const String settingsUpdateCheckFailurePrefix = 'Failed to check for updates: ';
const String settingsThemeAppearanceLabel = 'Theme & Appearance';
const String settingsThemeModeTitle = 'Theme Mode';
const String settingsThemeModeSubtitle = 'Appearance of the app';
const String settingsThemeLightLabel = 'Light';
const String settingsThemeDarkLabel = 'Dark';
const String settingsThemeSystemLabel = 'System';
const String settingsDynamicColorTitle = 'Dynamic Color';
const String settingsDynamicColorSubtitle = 'Use system colors (Material You)';
const String settingsGeneralLabel = 'General';
const String settingsCountryTitle = 'Country';
const String settingsCountrySubtitle = 'Content region for trending & explore';
const String settingsAboutLabel = 'About';
const String settingsCheckUpdatesTitle = 'Check for Updates';
const String settingsCheckingSubtitle = 'Checking...';
const String settingsCheckUpdatesSubtitle =
    'Check if a newer version is available';
const String settingsSelectCountryTitle = 'Select Country';
const String settingsSearchCountryHint = 'Search country...';

// Update dialog copy
const String updateDialogTitle = 'Update available';
const String updateDialogDownloadingMessage = 'Downloading update...';
const String updateDialogPermissionMissingMessage =
    'Permission not granted to install packages. Please try again and grant the permission.';
const String updateDialogDownloadFailurePrefix = 'Failed to download update: ';
const String updateDialogAvailableVersionPrefix =
    'A new version of the app is available: ';
const String updateDialogChangelogPrefix = 'CHANGELOG: ';
const String updateDialogDownloadActionLabel = 'Download update';

// Download dialog copy
const String downloadOptionsTitle = 'Download Options';
const String downloadVideoTitle = 'Download Video';
const String downloadVideoSubtitleFullQuality = 'Full quality with audio';
const String downloadVideoSubtitleWithAudio = 'Full quality video with audio';
const String downloadAudioOnlyTitle = 'Download Audio Only';
const String downloadAudioOnlySubtitle = 'Audio track only';
const String downloadAudioOnlySubtitleSmallSize =
    'Audio track only, smaller file size';

// Music UI copy
const String musicTabAppBarTitle = 'Music';
const String musicLoadErrorTitle = 'Could not load music';
const String musicLoadErrorMessage = 'Something went wrong. Try again.';
const String musicSectionYourChannels = 'Your Channels';
const String musicSectionFeaturedChannels = 'Artists You Might Like';
const int featuredChannelsMaxTotal = 10;
const String musicSectionExploreByGenre = 'Explore by Genre';
const String musicSectionContinueListening = 'Continue Listening';
const String musicSectionNewReleases = 'New Releases';
const String musicSectionInternationalTopHits = 'International Top Hits';
const String musicSectionTrendingMusic = 'Trending Music';
const String musicEmptyStateTitle = 'Your music, your way';
const String musicEmptyStateMessage =
    'Save some favorites to get personalized picks';

String musicBecauseYouLikedTitle(String videoTitle) =>
    'Because you liked "$videoTitle"';

// Trending and search heuristics
const Duration trendingMinDuration = Duration(minutes: 2);
const Duration trendingMaxDuration = Duration(minutes: 12);
const int personalizedMaxPerArtist = 4;
const int personalizedArtistQueryLimit = 5;
const int musicHomeMaxVideosPerQuery = 8;
const int localSuggestionsInsertQueryMinLength = 2;
const int localSuggestionsMaxResults = 10;

// Queue draggable sheet
const double queueSheetMinChildSize = 0.08;
const double queueSheetMaxChildSize = 1.0;
const List<double> queueSheetSnapSizes = [0.4];
const Duration queueSheetAnimationDuration = Duration(milliseconds: 500);

// Query/suggestion presets
const List<String> musicHomeQueries = [
  'top music',
  'new music releases',
  'popular songs',
  'hit songs',
  'music charts',
];

const List<String> predefinedSearchSuggestions = [
  'music',
  'gaming',
  'movies',
  'tutorials',
  'news',
  'comedy',
  'sports',
  'technology',
  'science',
  'education',
];

// Music genres for chips section
const List<MapEntry<String, String>> musicGenres = [
  MapEntry('Pop', 'Pop'),
  MapEntry('Hip-Hop', 'Hip Hop'),
  MapEntry('Rock', 'Rock'),
  MapEntry('R&B', 'R&B Soul'),
  MapEntry('Electronic', 'Electronic'),
  MapEntry('Latin', 'Latin'),
  MapEntry('K-Pop', 'KPop'),
  MapEntry('Jazz', 'Jazz'),
  MapEntry('Classical', 'Classical'),
];

// Trending query fallback map
const List<String> defaultTrendingQueries = [
  'trending videos',
  'popular videos',
  'trending today',
];

const Map<String, List<String>> trendingEnglishQueriesByCategory = {
  'music': ['trending music', 'top songs', 'new music'],
  'pop': ['top pop songs', 'pop music hits', 'best pop music'],
  'hip hop': ['hip hop music', 'rap songs', 'hip hop hits'],
  'rock': ['rock music', 'rock songs', 'rock hits'],
  'r&b soul': ['r&b music', 'soul music', 'rnb songs'],
  'r&b': ['r&b music', 'soul music', 'rnb songs'],
  'electronic': ['electronic music', 'edm songs', 'house music'],
  'latin': ['latin music', 'reggaeton hits', 'latin pop'],
  'kpop': ['kpop music', 'k-pop hits', 'korean pop songs'],
  'jazz': ['jazz music', 'jazz songs', 'best jazz'],
  'classical': ['classical music', 'classical songs', 'orchestra music'],
  'gaming': ['gaming', 'gameplay'],
  'film': ['new movies', 'movie trailers', 'film reviews'],
  'movies': ['new movies', 'movie trailers', 'film reviews'],
  'now': ['trending videos', 'popular videos', 'trending today'],
};

// Country/language helpers
const Map<String, String> newMusicSuffixByCountry = {
  'IT': 'nuova musica',
  'FR': 'nouvelle musique',
  'ES': 'nueva música',
  'MX': 'nueva música',
  'AR': 'nueva música',
  'DE': 'neue musik',
  'AT': 'neue musik',
  'CH': 'neue musik',
  'RU': 'новая музыка',
  'KR': '신곡',
  'BR': 'nova música',
  'PT': 'nova música',
  'CN': '新歌',
  'HK': '新歌',
  'TW': '新歌',
  'TR': 'yeni müzik',
  'ID': 'musik baru',
  'NL': 'nieuwe muziek',
  'BE': 'nieuwe muziek',
  'SE': 'ny musik',
  'DK': 'ny musik',
  'NO': 'ny musikk',
  'PL': 'nowa muzyka',
  'RO': 'muzică nouă',
  'CZ': 'nová hudba',
  'VN': 'nhạc mới',
  'TH': 'เพลงใหม่',
  'FI': 'uusi musiikki',
};

// Country to language code map
const Map<String, String> countryToLanguage = {
  'US': 'en',
  'GB': 'en',
  'IT': 'it',
  'FR': 'fr',
  'ES': 'es',
  'DE': 'de',
  'RU': 'ru',
  'JP': 'ja',
  'CN': 'zh',
  'IN': 'hi',
  'BR': 'pt',
  'MX': 'es',
  'CA': 'en',
  'AU': 'en',
  'KR': 'ko',
  'TR': 'tr',
  'ID': 'id',
  'NL': 'nl',
  'SE': 'sv',
  'PL': 'pl',
  'RO': 'ro',
  'CZ': 'cs',
  'PT': 'pt',
  'VN': 'vi',
  'TH': 'th',
  'AR': 'es',
  'HK': 'zh',
  'DK': 'da',
  'FI': 'fi',
  'NO': 'nb',
  'BE': 'nl',
};

// Localized trending query overrides per category/language
const Map<String, Map<String, List<String>>> localizedTrendingOverrides = {
  'music': {
    'it': [
      'musica di tendenza',
      'nuova musica italiana',
      'canzoni del momento',
    ],
    'fr': [
      'musique tendance france',
      'nouvelle musique française',
      'hits musique',
    ],
    'es': ['música de moda', 'nueva música', 'canciones populares'],
    'de': ['aktuelle musik', 'neue musik hits', 'musik trends'],
    'ru': ['музыка тренды', 'новая музыка', 'популярные песни'],
    'ja': ['音楽トレンド', '新曲', '人気音楽'],
    'ko': ['최신 음악', '인기 음악', '신곡'],
    'pt': ['música popular', 'novas músicas', 'hits musicais'],
    'zh': ['流行音乐', '新歌', '热门音乐'],
    'hi': ['नई संगीत', 'ट्रेंडिंग संगीत', 'बॉलीवुड हिट्स'],
    'tr': ['müzik trendleri', 'yeni müzik', 'popüler şarkılar'],
    'id': ['musik terbaru', 'lagu populer', 'musik trending'],
    'nl': ['trending muziek', 'nieuwe muziek', 'populaire nummers'],
    'sv': ['trending musik', 'ny musik', 'populär musik'],
    'pl': ['muzyka trendy', 'nowa muzyka', 'popularne piosenki'],
    'ro': ['muzică nouă', 'muzică populară', 'hituri muzicale'],
    'cs': ['hudba trendy', 'nová hudba', 'populární písně'],
    'vi': ['nhạc xu hướng', 'nhạc mới', 'bài hát phổ biến'],
    'th': ['เพลงฮิต', 'เพลงใหม่', 'เพลงไทย'],
    'da': ['trending musik', 'ny musik', 'populær musik'],
    'fi': ['musiikkitrendit', 'uusi musiikki', 'suositut biisit'],
    'nb': ['musikk trending', 'ny musikk', 'populær musikk'],
  },
  'now': {
    'it': ['video di tendenza', 'viral oggi', 'più visti oggi'],
    'fr': ['vidéos tendance', 'viral france', 'plus regardés'],
    'es': ['videos tendencia', 'viral hoy', 'más vistos'],
    'de': ['trending videos', 'viral deutschland', 'meistgesehene videos'],
    'ru': ['трендовые видео', 'вирусное видео', 'популярное сегодня'],
    'ja': ['トレンド動画', 'バイラル動画', '人気動画'],
    'ko': ['트렌드 동영상', '인기 동영상', '바이럴'],
    'pt': ['vídeos tendência', 'viral brasil', 'mais assistidos'],
    'zh': ['热门视频', '病毒视频', '今日热点'],
    'hi': ['ट्रेंडिंग वीडियो', 'वायरल वीडियो', 'आज के वीडियो'],
    'tr': ['trend videolar', 'viral video', 'popüler videolar'],
    'id': ['video trending', 'viral indonesia', 'video populer'],
    'nl': ['trending video\'s', 'virale video\'s', 'populaire video\'s'],
    'sv': ['trending videor', 'virala videor', 'populära videor'],
    'pl': ['trendy wideo', 'wirusowe wideo', 'popularne filmy'],
    'ro': ['videoclipuri trending', 'viral azi', 'cele mai vizionate'],
    'cs': ['trendy videa', 'virální videa', 'populární videa'],
    'vi': ['video xu hướng', 'video viral', 'video phổ biến'],
    'th': ['วิดีโอยอดนิยม', 'วิดีโอไวรัล', 'วิดีโอเทรนด์'],
    'da': ['trending videoer', 'virale videoer', 'populære videoer'],
    'fi': ['trendit videot', 'viraalit videot', 'suositut videot'],
    'nb': ['trending videoer', 'virale videoer', 'populære videoer'],
  },
  'film': {
    'it': ['trailer film', 'cinema italiano', 'nuovi film'],
    'fr': ['bandes annonces', 'cinéma français', 'nouveaux films'],
    'es': ['trailers cine', 'películas nuevas', 'cine español'],
    'de': ['film trailer', 'neue filme', 'kino deutschland'],
    'ru': ['трейлеры фильмов', 'новые фильмы', 'кино 2025'],
    'ja': ['映画予告', '新作映画', '日本映画'],
    'ko': ['영화 예고편', '신작 영화', '한국 영화'],
    'pt': ['trailers filmes', 'novos filmes', 'cinema brasileiro'],
    'zh': ['电影预告片', '新电影', '中国电影'],
    'hi': ['फिल्म ट्रेलर', 'नई बॉलीवुड फिल्में', 'हिंदी फिल्में'],
    'tr': ['film fragmanları', 'yeni filmler', 'sinema türkiye'],
    'id': ['trailer film', 'film terbaru', 'bioskop indonesia'],
    'nl': ['film trailers', 'nieuwe films', 'bioscoop nederland'],
    'sv': ['film trailers', 'nya filmer', 'bio sverige'],
    'pl': ['trailery filmów', 'nowe filmy', 'kino polska'],
    'ro': ['trailer filme', 'filme noi', 'cinema romania'],
    'cs': ['trailery filmů', 'nové filmy', 'kino česko'],
    'vi': ['trailer phim', 'phim mới', 'phim việt nam'],
    'th': ['ตัวอย่างหนัง', 'หนังใหม่', 'ภาพยนตร์ไทย'],
    'da': ['film trailers', 'nye film', 'biograf danmark'],
    'fi': ['elokuva traileri', 'uudet elokuvat', 'elokuva suomi'],
    'nb': ['film trailere', 'nye filmer', 'kino norge'],
  },
  'gaming': {
    'it': ['gaming italiano', 'gameplay ita', 'videogiochi tendenza'],
    'fr': ['gaming france', 'gameplay fr', 'jeux vidéo tendance'],
    'es': ['gaming español', 'gameplay español', 'videojuegos trending'],
    'de': ['gaming deutsch', 'gameplay deutsch', 'spiele trending'],
    'ru': ['игровые видео', 'геймплей', 'игры тренды'],
    'ja': ['ゲーム動画', 'ゲームプレイ', '人気ゲーム'],
    'ko': ['게임 동영상', '게임플레이', '인기 게임'],
    'pt': ['gaming brasil', 'gameplay pt', 'jogos tendência'],
    'zh': ['游戏视频', '游戏直播', '热门游戏'],
    'hi': ['गेमिंग वीडियो', 'गेमप्ले हिंदी', 'वायरल गेम'],
    'tr': ['gaming türkçe', 'gameplay türkiye', 'oyun videoları'],
    'id': ['gaming indonesia', 'gameplay indonesia', 'game populer'],
    'nl': ['gaming nederland', 'gameplay nl', 'populaire games'],
    'sv': ['gaming svenska', 'gameplay svenska', 'populära spel'],
    'pl': ['gaming polska', 'gameplay pl', 'gry trending'],
    'ro': ['gaming romania', 'gameplay ro', 'jocuri trending'],
    'cs': ['gaming česky', 'gameplay cz', 'hry trending'],
    'vi': ['gaming việt nam', 'gameplay vi', 'game phổ biến'],
    'th': ['เกมมิ่งไทย', 'เล่นเกม', 'เกมยอดนิยม'],
    'da': ['gaming dansk', 'gameplay dk', 'populære spil'],
    'fi': ['gaming suomi', 'gameplay fi', 'suositut pelit'],
    'nb': ['gaming norsk', 'gameplay no', 'populære spill'],
  },
};
