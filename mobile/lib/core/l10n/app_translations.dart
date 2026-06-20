import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/locale_provider.dart';
import 'package:kickpro/shared/models/announcement_models.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/video_models.dart';

final trProvider = Provider<Tr>((ref) {
  final locale = ref.watch(localeProvider);
  return locale.languageCode == 'fr' ? const _TrFr() : const _TrEn();
});

/// Rebuilds descendants when locale changes (unlike ProviderScope.read).
class TrScope extends InheritedWidget {
  const TrScope({required this.tr, required super.child, super.key});

  final Tr tr;

  static Tr of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TrScope>();
    assert(scope != null, 'TrScope not found above this context');
    return scope!.tr;
  }

  @override
  bool updateShouldNotify(TrScope oldWidget) => tr != oldWidget.tr;
}

extension TrContext on BuildContext {
  Tr get tr => TrScope.of(this);
}

extension TrWidgetRef on WidgetRef {
  Tr get tr => watch(trProvider);
}

abstract class Tr {
  const Tr();

  // ── General ──
  String get appName;
  String get retry;
  String get cancel;
  String get save;
  String get delete;
  String get search;
  String get loading;
  String get none;

  // ── Auth ──
  String get loginTagline;
  String get email;
  String get emailHint;
  String get password;
  String get passwordHint;
  String get passwordMinHint;
  String get signIn;
  String get newHereCreate;
  String get trustedBy;
  String get createAccount;
  String get joinKickpro;
  String get iAmA;
  String get player;
  String get scout;
  String get scoutAccountCreated;

  // ── Errors ──
  String get geminiRateLimit;
  String get aiTimeout;
  String get cannotReachServer;

  // ── Nav ──
  String get navFeed;
  String get navDrills;
  String get navPost;
  String get navMatches;
  String get navProfile;
  String get navSearch;
  String get navBookmarks;
  String get navVideos;
  String get bookmarks;
  String get noBookmarksYet;

  // ── Profile setup ──
  String get buildProfile;
  String get tellScouts;
  String get fullName;
  String get fullNameHint;
  String get dateOfBirth;
  String get selectDate;
  String get city;
  String get cityHint;
  String get position;
  String get preferredFoot;
  String get heightCm;
  String get weightKg;
  String get bioOptional;
  String get bioHint;
  String get continueToSkills;
  String get selectDob;

  // ── Skills setup ──
  String get rateSkills;
  String get dragSlider;
  String get saveAndView;

  // ── Skill labels ──
  String get dribbling;
  String get shooting;
  String get passing;
  String get speed;
  String get heading;
  String get stamina;
  String get strengths;
  String get weaknesses;

  // ── Profile ──
  String get myProfile;
  String get editProfileTooltip;
  String get skills;
  String get certs;
  String get score;
  String get overview;
  String get browseCourses;
  String get noCertsYet;
  String get height;
  String get weight;
  String get born;
  String get bio;
  String get followers;
  String get following;
  String get follow;
  String get currentlyRecovering;
  String get injuryStatus;
  String get injuryStatusSubtitle;
  String get shareProfile;
  String get profileQrTitle;
  String get cannotJoinWhileInjured;

  // ── Edit profile ──
  String get editProfile;
  String get skillRatings;
  String get saveChanges;
  String get completeAllFields;
  String get profileUpdated;

  // ── Profile photo ──
  String get viewProfilePicture;
  String get editProfilePicture;
  String get deleteProfilePicture;
  String get adjustPhoto;
  String get couldNotLoadPhoto;
  String get deletePhotoTitle;
  String get deletePhotoBody;
  String get profilePhotoUpdated;
  String get profilePhotoDeleted;

  // ── Feed ──
  String get feed;
  String get noPostsYet;
  String get editPost;
  String get caption;
  String get skillTagOptional;
  String get share;

  // ── Create post ──
  String get createPost;
  String get text;
  String get photo;
  String get video;
  String get captionHintText;
  String get captionHintMedia;
  String get post;
  String get pickPhotoPost;
  String get pickVideoPost;
  String get writeSomethingFirst;
  String get postShared;

  // ── Comments ──
  String get comments;
  String get noCommentsYet;
  String get commentLabel;
  String get addCommentHint;

  // ── Drills ──
  String get drillProgression;
  String get leaderboard;
  String get aiCoach;
  String get completed;
  String get current;
  String get locked;
  String get submitDrillVideo;
  String get rules;
  String get noVideoSelected;
  String get videoReady;
  String get recordPickVideo;
  String get changeVideo;
  String get submitForReview;
  String get selectVideoFirst;
  String get submittedForReview;

  // ── Drill levels ──
  String get beginner;
  String get intermediate;
  String get advanced;

  // ── Matches ──
  String get bookMatch;
  String get matches;
  String get open;
  String get myMatches;
  String get noOpenMatches;
  String get noMyMatches;

  // ── Match status ──
  String get statusOpen;
  String get statusFull;
  String get statusDone;
  String get statusCancelled;

  // ── Book match flow ──
  String get chooseCity;
  String get chooseStadium;
  String get pickDateTime;
  String get matchDetails;
  String get continueBtn;
  String get confirmBooking;
  String get completeBookingSteps;
  String get matchBooked;
  String get selectACity;
  String get selectAStadium;
  String get selectTimeSlot;
  String get wherePlay;
  String get searchByName;
  String get noStadiumsFound;
  String get allowedFormats;
  String get photos;
  String get selectADate;
  String get availableSlots;
  String get pickDateToSeeSlots;
  String get noSlotsForDate;
  String get matchFormat;
  String get ageRange;
  String get gender;

  // ── Match gender ──
  String get menOnly;
  String get womenOnly;
  String get mixed;

  // ── Match detail ──
  String get matchDetailsTitle;
  String get players;
  String get requestToJoin;
  String get markCompleted;
  String get cancelMatch;
  String get openChat;
  String get ratePlayers;
  String get joinPending;
  String get cancelMatchTitle;
  String get cancelMatchBody;
  String get keep;
  String get cancelMatchBtn;
  String get joinRequestSent;
  String get matchCompletedToast;
  String get matchCancelledToast;
  String get approved;
  String get pending;
  String get rejected;

  // ── Match chat ──
  String get matchChat;
  String get noChatMessages;
  String get messageTeamHint;

  // ── Match rating ──
  String get ratePlayersTitle;
  String get howDidPerform;
  String get rateInstructions;
  String get performance;
  String get punctuality;
  String get teamwork;
  String get behavior;
  String get submitRating;
  String get submittedRatings;
  String get selectPlayerToRate;
  String get ratingSubmitted;

  // ── Courses ──
  String get certificationCourses;
  String get courseDescription;
  String get noCoursesYet;
  String get certified;
  String get comingSoon;
  String get course;
  String get youEarnedCert;
  String get lessons;
  String get tapLessonToRead;
  String get noLessonsYet;
  String get quiz;
  String get tapToReadLesson;
  String get takeFinalQuiz;
  String get finalQuizLesson;

  // ── Quiz ──
  String get courseQuiz;
  String get submitQuiz;
  String get quizResult;
  String get quizPassed;
  String get keepPractising;
  String get certificationEarned;
  String get backToCourse;
  String get answerAllQuestions;

  // ── AI ──
  String get aiCoachTitle;
  String get aiCoachSubtitle;
  String get drillRecommendations;
  String get drillRecommendationsDesc;
  String get mealPlan;
  String get mealPlanDesc;
  String get recoveryPlan;
  String get recoveryPlanDesc;
  String get recommendedDrills;
  String get noDrillRecommendations;
  String get recoveryPlanTitle;
  String get recoveryPlanSubtitle;
  String get injuryType;
  String get injuryTypeHint;
  String get bodyPart;
  String get bodyPartHint;
  String get severity;
  String get severityHint;
  String get required;
  String get generatePlan;
  String get scoreExplanation;
  String get scoutAssistant;
  String get scoutAssistSubtitle;
  String get scoutAssistHint;
  String get findPlayers;
  String get describeWhatLookingFor;
  String get explainWithAi;

  // ── Credibility ──
  String get credibilityScore;
  String get credibilitySubtitle;
  String get credibilityExplain;
  String get factorDrills;
  String get factorRatings;
  String get factorCerts;
  String get factorParticipation;
  String get factorVideoRatings;

  // ── Search ──
  String get findPlayersTitle;
  String get scoutAssistTooltip;
  String get searchByPlayer;
  String get allCities;
  String get searchBtn;
  String get resetBtn;
  String get noPlayersMatch;
  String get certifications;

  // ── Leaderboard ──
  String get leaderboardTitle;
  String get mostMatches;
  String get mostBadges;
  String get bestRated;
  String get noPlayersRanked;
  String get filterByPosition;
  String get filterByAgeGroup;
  String get allPositions;
  String get allAgeGroups;
  String get ageGroupU18;
  String get ageGroupU21;
  String get ageGroupOpen;
  String get listView;
  String get mapView;

  // ── Scout notes ──
  String scoutNotesTitle(String playerName);
  String get privateNotes;
  String get noNotesYet;
  String get technicalAbility;
  String get potential;
  String get scoutNoteLabel;
  String get saveNote;
  String get deleteNote;
  String get scoutNoteSaved;
  String get scoutNoteDeleted;
  String get scoutNoteInvalid;

  // ── Admin nav ──
  String get adminHome;
  String get adminVenues;
  String get adminDrills;
  String get adminCourses;
  String get adminManage;

  // ── Admin dashboard ──
  String get adminDashboard;
  String get statPlayers;
  String get statPendingDrills;
  String get statActiveMatches;
  String get statFlaggedPosts;
  String get statTotalUsers;
  String get quickActions;
  String get addVenue;
  String get reviewDrills;
  String get generateCourse;
  String get moderatePosts;

  // ── Admin venues ──
  String get venues;
  String get createVenue;
  String get editVenue;
  String get name;
  String get address;
  String get phoneNumber;
  String get description;
  String get pricePerHourMad;
  String get numberOfPitches;
  String get openTime;
  String get closeTime;
  String get grassType;
  String get natural;
  String get artificial;
  String get hybrid;
  String get pitchTypes;
  String get nameAddressRequired;
  String get selectOneFormat;
  String get venueCreated;
  String get venueUpdated;
  String get edit;
  String get mapLocation;
  String get tapMapToPin;

  // ── Admin drills ──
  String get drills;
  String get submissions;
  String get drillLibrary;
  String get noPendingSubmissions;
  String get scoreIfApproving;
  String get approve;
  String get reject;
  String get createDrill;
  String get title;
  String get progressionOrder;
  String get saveDrill;

  // ── Admin courses ──
  String get courses;
  String get aiPlusCreate;
  String get noMediaAttached;
  String get lessonMediaUploaded;
  String get deleteCourse;
  String get createCourseManually;
  String get publishCourse;
  String get coursePublished;
  String get courseLevel;
  String get addLesson;
  String get lessonContent;
  String get finalLessonQuiz;
  String get addQuestion;
  String get completeFinalQuiz;
  String get attachMedia;
  String get chooseImageOrVideo;
  String get chooseDocument;
  String optionN(int n);

  // ── Admin manage ──
  String get manage;
  String get users;
  String get posts;
  String get active;
  String get banned;
  String get agentPendingVerification;
  String get ban;
  String get unban;
  String get verifyAgent;
  String get agentVerified;
  String get flaggedOnly;
  String get flag;
  String get unflag;
  String get remove;
  String get postRemoved;

  // ── Generate course ──
  String get generateCourseTitle;
  String get generateCourseSubtitle;
  String get courseTitle;
  String get briefDescription;
  String get titleRequired;
  String get descriptionRequired;
  String get generateWithAi;
  String get quizQuestions;

  // ── Settings / Language ──
  String get language;
  String get english;
  String get french;

  String get announcements;
  String get noAnnouncementsYet;
  String get createAnnouncement;
  String get announcementType;
  String get official;

  String get notifications;
  String get noNotificationsYet;
  String get markAllRead;

  // ── Squads ──
  String get mySquads;
  String get createSquad;
  String get noSquadsYet;
  String get squadName;
  String get squadNameHint;
  String get squadCreated;
  String get captain;
  String get inviteToSquad;
  String get noCaptainSquads;
  String get playerInvitedToSquad;
  String get joinSquads;
  String get joinRequestPending;
  String get alreadyInSquad;
  String get incomingJoinRequests;
  String get noSquadsInCity;

  // ── Clubs ──
  String get clubsAndAcademies;
  String get clubsDescription;
  String get noClubsYet;
  String get browseClubs;

  // ── Referrals ──
  String get referralCode;
  String get referralCodeOptional;
  String get referralCodeHint;
  String get referralCodeCopied;
  String get copyCode;

  // ── Discovery ──
  String get playersNearby;
  String get openMatches;
  String get upcomingMatches;
  String get topPlayers;

  // ── Challenges ──
  String get weeklyChallenge;
  String get noActiveChallenge;
  String get submitChallenge;
  String get challengeSubmissions;
  String get vote;
  String get videoUrl;
  String get videoUrlHint;
  String get challengeSubmitted;
  String get votes;

  // ── Compare players ──
  String get comparePlayers;
  String get compareMode;
  String get selectTwoPlayers;
  String get playerA;
  String get playerB;
  String get compare;

  // ── Timeline ──
  String get timeline;
  String get noTimelineEvents;

  // ── Agent ──
  String get agent;
  String get agentHome;
  String get navTrials;
  String get navMessages;
  String get agentAccountCreated;
  String get noConversationsYet;
  String get typeMessage;
  String get send;
  String get sendMessage;
  String get you;
  String get confirmDeletePost;
  String get confirmDeleteTrial;

  // ── AI video feedback ──
  String get analyzeWithAi;
  String get aiNoResult;
  String get videoScoutingReport;

  // ── Empty states ──
  String get noDrillsInLevel;
  String get noChallengeSubmissions;
  String get noMessagesYet;

  // ── Localized enum labels ──
  String positionLabel(PlayerPosition position);
  String preferredFootLabel(PreferredFoot foot);
  String matchGenderLabel(MatchGender gender);
  String drillLevelLabel(DrillLevel level);
  String targetSkillLabel(TargetSkill skill);
  String announcementTypeLabel(AnnouncementType type);

  // ── Format helpers (with placeholders) ──
  String nYearsOld(int n);
  String nDrillsAndCerts(int drills, int certs);
  String avgDrillScore(String score);
  String credibilityN(int n) => 'Credibility $n/100';
  String noStadiumsInCity(String city) => 'No stadiums in $city yet.\nTry another city.';
  String playersMax(int n) => '$n players max';
  String target(String skill) => 'Target: $skill';
  String nLessons(int n) => '$n lessons';
  String nMatches(int n) => '$n matches';
  String nBadges(int n) => '$n badges';
  String nPitches(int n) => '$n pitches';
  String earnedDate(String date) => 'Earned $date';
  String questionN(int n) => 'Question $n';
  String lessonN(int n) => 'Lesson $n';
  String rank(int n) => '#$n';
  String nPlayersMatched(int n) => '$n player(s) matched';
  String nPlayersConfirmed(int cur, int max) => '$cur/$max players confirmed';
  String agesRange(int min, int max) => 'Ages $min–$max';
  String organizerName(String name) => 'Organizer: $name';
  String pricePerHr(String price) => '$price MAD/hr';
  String quizScore(int pct, int correct, int total) => '$pct% ($correct/$total correct)';
  String nQuizQuestions(int n) => '$n quiz questions';
  String nMembers(int n) => '$n members';
  String squadCaptain(String name) => 'Captain: $name';
  String discoveryInCity(String city) => 'Discover $city';
  String nReferrals(int n) => '$n referral(s)';
  String referralShareMessage(String code) => 'Join me on KickPro! Use my referral code: $code';
}

class _TrEn extends Tr {
  const _TrEn();

  @override String get appName => 'KickPro';
  @override String get retry => 'Retry';
  @override String get cancel => 'Cancel';
  @override String get save => 'Save';
  @override String get delete => 'Delete';
  @override String get search => 'Search';
  @override String get loading => 'Loading...';
  @override String get none => 'None';

  @override String get loginTagline => 'Your digital football CV';
  @override String get email => 'Email';
  @override String get emailHint => 'you@example.com';
  @override String get password => 'Password';
  @override String get passwordHint => '••••••••';
  @override String get passwordMinHint => 'Min. 8 characters';
  @override String get signIn => 'Sign In';
  @override String get newHereCreate => 'New here? Create an account';
  @override String get trustedBy => 'Trusted by players and scouts across Morocco';
  @override String get createAccount => 'Create Account';
  @override String get joinKickpro => 'Join KickPro as a player or scout';
  @override String get iAmA => 'I am a';
  @override String get player => 'Player';
  @override String get scout => 'Scout';
  @override String get scoutAccountCreated => 'Scout account created';

  @override String get geminiRateLimit => 'Gemini rate limit reached. Wait 1–2 minutes and try one feature at a time.';
  @override String get aiTimeout => 'AI request timed out. Gemini may be rate-limited — wait a minute and retry.';
  @override String get cannotReachServer => 'Cannot reach server. Check Docker is running and the API URL is correct.';

  @override String get navFeed => 'Feed';
  @override String get navDrills => 'Drills';
  @override String get navPost => 'Post';
  @override String get navMatches => 'Matches';
  @override String get navProfile => 'Profile';
  @override String get navSearch => 'Search';
  @override String get navBookmarks => 'Bookmarks';
  @override String get navVideos => 'Videos';
  @override String get bookmarks => 'Bookmarks';
  @override String get noBookmarksYet => 'No bookmarked players yet.\nTap the bookmark icon on a player to save them.';

  @override String get buildProfile => 'Build your profile';
  @override String get tellScouts => 'Tell scouts who you are on the pitch';
  @override String get fullName => 'Full name';
  @override String get fullNameHint => 'Youssef Benali';
  @override String get dateOfBirth => 'Date of birth';
  @override String get selectDate => 'Select date';
  @override String get city => 'City';
  @override String get cityHint => 'Casablanca';
  @override String get position => 'Position';
  @override String get preferredFoot => 'Preferred foot';
  @override String get heightCm => 'Height (cm)';
  @override String get weightKg => 'Weight (kg)';
  @override String get bioOptional => 'Bio (optional)';
  @override String get bioHint => 'Fast winger from Casablanca...';
  @override String get continueToSkills => 'Continue to Skills';
  @override String get selectDob => 'Please select your date of birth';

  @override String get rateSkills => 'Rate your skills';
  @override String get dragSlider => 'Drag each slider from 1 to 10 stars';
  @override String get saveAndView => 'Save & View Profile';

  @override String get dribbling => 'Dribbling';
  @override String get shooting => 'Shooting';
  @override String get passing => 'Passing';
  @override String get speed => 'Speed';
  @override String get heading => 'Heading';
  @override String get stamina => 'Stamina';
  @override String get strengths => 'Strengths';
  @override String get weaknesses => 'Weaknesses';

  @override String get myProfile => 'My Profile';
  @override String get editProfileTooltip => 'Edit profile';
  @override String get skills => 'Skills';
  @override String get certs => 'Certs';
  @override String get score => 'Score';
  @override String get overview => 'Overview';
  @override String get browseCourses => 'Browse Courses';
  @override String get noCertsYet => 'No certifications yet. Complete a course quiz to earn your first badge.';
  @override String get height => 'Height';
  @override String get weight => 'Weight';
  @override String get born => 'Born';
  @override String get bio => 'Bio';
  @override String get followers => 'Followers';
  @override String get following => 'Following';
  @override String get follow => 'Follow';
  @override String get currentlyRecovering => 'Currently Recovering';
  @override String get injuryStatus => 'Injury status';
  @override String get injuryStatusSubtitle => 'Mark yourself as recovering to pause match activity';
  @override String get shareProfile => 'Share profile';
  @override String get profileQrTitle => 'Profile QR Code';
  @override String get cannotJoinWhileInjured => 'You cannot join matches while recovering from an injury';

  @override String get editProfile => 'Edit Profile';
  @override String get skillRatings => 'Skill ratings';
  @override String get saveChanges => 'Save changes';
  @override String get completeAllFields => 'Complete all required fields';
  @override String get profileUpdated => 'Profile updated';

  @override String get viewProfilePicture => 'View profile picture';
  @override String get editProfilePicture => 'Edit profile picture';
  @override String get deleteProfilePicture => 'Delete profile picture';
  @override String get adjustPhoto => 'Adjust photo';
  @override String get couldNotLoadPhoto => 'Could not load photo';
  @override String get deletePhotoTitle => 'Delete profile picture?';
  @override String get deletePhotoBody => 'Your profile picture will be removed.';
  @override String get profilePhotoUpdated => 'Profile photo updated';
  @override String get profilePhotoDeleted => 'Profile photo deleted';

  @override String get feed => 'Feed';
  @override String get noPostsYet => 'No posts yet. Tap + to share your first update.';
  @override String get editPost => 'Edit post';
  @override String get caption => 'Caption';
  @override String get skillTagOptional => 'Skill tag (optional)';
  @override String get share => 'Share';

  @override String get createPost => 'Create post';
  @override String get text => 'Text';
  @override String get photo => 'Photo';
  @override String get video => 'Video';
  @override String get captionHintText => 'Share a thought with the squad...';
  @override String get captionHintMedia => 'Describe your post...';
  @override String get post => 'Post';
  @override String get pickPhotoPost => 'Pick photo & post';
  @override String get pickVideoPost => 'Pick video & post';
  @override String get writeSomethingFirst => 'Write something first';
  @override String get postShared => 'Post shared';

  @override String get comments => 'Comments';
  @override String get noCommentsYet => 'No comments yet';
  @override String get commentLabel => 'Comment';
  @override String get addCommentHint => 'Add a comment...';

  @override String get drillProgression => 'Drill Progression';
  @override String get leaderboard => 'Leaderboard';
  @override String get aiCoach => 'AI Coach';
  @override String get completed => 'Completed';
  @override String get current => 'Current';
  @override String get locked => 'Locked';
  @override String get submitDrillVideo => 'Submit drill video';
  @override String get rules => 'Rules';
  @override String get noVideoSelected => 'No video selected';
  @override String get videoReady => 'Video ready to submit';
  @override String get recordPickVideo => 'Record / Pick Video';
  @override String get changeVideo => 'Change Video';
  @override String get submitForReview => 'Submit for Review';
  @override String get selectVideoFirst => 'Select a video first';
  @override String get submittedForReview => 'Submitted for admin review';

  @override String get beginner => 'Beginner';
  @override String get intermediate => 'Intermediate';
  @override String get advanced => 'Advanced';

  @override String get bookMatch => 'Book Match';
  @override String get matches => 'Matches';
  @override String get open => 'Open';
  @override String get myMatches => 'My Matches';
  @override String get noOpenMatches => 'No open matches nearby yet.\nBe the first to book one!';
  @override String get noMyMatches => 'You have no matches yet.\nTap Book Match to create one.';

  @override String get statusOpen => 'OPEN';
  @override String get statusFull => 'FULL';
  @override String get statusDone => 'DONE';
  @override String get statusCancelled => 'CANCELLED';

  @override String get chooseCity => 'Choose city';
  @override String get chooseStadium => 'Choose stadium';
  @override String get pickDateTime => 'Pick date & time';
  @override String get matchDetails => 'Match details';
  @override String get continueBtn => 'Continue';
  @override String get confirmBooking => 'Confirm Booking';
  @override String get completeBookingSteps => 'Complete all booking steps';
  @override String get matchBooked => 'Match booked!';
  @override String get selectACity => 'Select a city';
  @override String get selectAStadium => 'Select a stadium';
  @override String get selectTimeSlot => 'Select an available time slot';
  @override String get wherePlay => 'Where do you want to play?';
  @override String get searchByName => 'Search by name';
  @override String get noStadiumsFound => 'No stadiums found';
  @override String get allowedFormats => 'Allowed formats';
  @override String get photos => 'Photos';
  @override String get selectADate => 'Select a date';
  @override String get availableSlots => 'Available slots';
  @override String get pickDateToSeeSlots => 'Pick a date to see time slots';
  @override String get noSlotsForDate => 'No slots for this date';
  @override String get matchFormat => 'Match format';
  @override String get ageRange => 'Age range';
  @override String get gender => 'Gender';

  @override String get menOnly => 'Men only';
  @override String get womenOnly => 'Women only';
  @override String get mixed => 'Mixed';

  @override String get matchDetailsTitle => 'Match Details';
  @override String get players => 'Players';
  @override String get requestToJoin => 'Request to Join';
  @override String get markCompleted => 'Mark as Completed';
  @override String get cancelMatch => 'Cancel Match';
  @override String get openChat => 'Open Chat';
  @override String get ratePlayers => 'Rate Players';
  @override String get joinPending => 'Your join request is pending approval.';
  @override String get cancelMatchTitle => 'Cancel match?';
  @override String get cancelMatchBody => 'This cannot be undone.';
  @override String get keep => 'Keep';
  @override String get cancelMatchBtn => 'Cancel match';
  @override String get joinRequestSent => 'Join request sent';
  @override String get matchCompletedToast => 'Match completed — rate your teammates!';
  @override String get matchCancelledToast => 'Match cancelled';
  @override String get approved => 'Approved';
  @override String get pending => 'Pending';
  @override String get rejected => 'Rejected';

  @override String get matchChat => 'Match Chat';
  @override String get noChatMessages => 'No messages yet.\nSay hi to your teammates!';
  @override String get messageTeamHint => 'Message your team...';

  @override String get ratePlayersTitle => 'Rate Players';
  @override String get howDidPerform => 'How did your teammates perform?';
  @override String get rateInstructions => 'Rate on performance, punctuality, teamwork, and behavior (1–5).';
  @override String get performance => 'Performance';
  @override String get punctuality => 'Punctuality';
  @override String get teamwork => 'Teamwork';
  @override String get behavior => 'Behavior';
  @override String get submitRating => 'Submit Rating';
  @override String get submittedRatings => 'Submitted ratings';
  @override String get selectPlayerToRate => 'Select a player to rate';
  @override String get ratingSubmitted => 'Rating submitted';

  @override String get certificationCourses => 'Certification Courses';
  @override String get courseDescription => 'Complete lessons and pass the final quiz to earn badges that boost your credibility.';
  @override String get noCoursesYet => 'No courses available yet';
  @override String get certified => 'Certified';
  @override String get comingSoon => 'Coming soon';
  @override String get course => 'Course';
  @override String get youEarnedCert => 'You earned this certification!';
  @override String get lessons => 'Lessons';
  @override String get tapLessonToRead => 'Tap a lesson to read the full content.';
  @override String get noLessonsYet => 'This course has no lessons yet. An admin needs to add content before you can take the quiz.';
  @override String get quiz => 'Quiz';
  @override String get tapToReadLesson => 'Tap to read full lesson';
  @override String get takeFinalQuiz => 'Take Final Quiz';
  @override String get finalQuizLesson => 'Final quiz lesson';

  @override String get courseQuiz => 'Course Quiz';
  @override String get submitQuiz => 'Submit Quiz';
  @override String get quizResult => 'Quiz Result';
  @override String get quizPassed => 'Quiz Passed!';
  @override String get keepPractising => 'Keep Practising';
  @override String get certificationEarned => 'Certification Earned';
  @override String get backToCourse => 'Back to Course';
  @override String get answerAllQuestions => 'Please answer all questions';

  @override String get aiCoachTitle => 'AI Coach';
  @override String get aiCoachSubtitle => 'Personalized football coaching powered by Gemini.';
  @override String get drillRecommendations => 'Drill Recommendations';
  @override String get drillRecommendationsDesc => 'Drills tailored to your skill profile';
  @override String get mealPlan => 'Meal Plan';
  @override String get mealPlanDesc => 'Football-specific nutrition for your position';
  @override String get recoveryPlan => 'Recovery Plan';
  @override String get recoveryPlanDesc => 'Return-to-play guidance after an injury';
  @override String get recommendedDrills => 'Recommended Drills';
  @override String get noDrillRecommendations => 'No drill recommendations right now. Complete your skills profile first.';
  @override String get recoveryPlanTitle => 'Recovery Plan';
  @override String get recoveryPlanSubtitle => 'Describe your injury for football-specific recovery guidance.';
  @override String get injuryType => 'Injury type';
  @override String get injuryTypeHint => 'e.g. muscle strain, sprain';
  @override String get bodyPart => 'Body part';
  @override String get bodyPartHint => 'e.g. hamstring, ankle';
  @override String get severity => 'Severity';
  @override String get severityHint => 'mild, moderate, or severe';
  @override String get required => 'Required';
  @override String get generatePlan => 'Generate Plan';
  @override String get scoreExplanation => 'Score Explanation';
  @override String get scoutAssistant => 'Scout AI Assistant';
  @override String get scoutAssistSubtitle => 'Describe the player profile you need in plain English.';
  @override String get scoutAssistHint => 'e.g. Fast strikers in Casablanca with good dribbling';
  @override String get findPlayers => 'Find Players';
  @override String get describeWhatLookingFor => 'Describe what you are looking for';
  @override String get explainWithAi => 'Explain with AI';

  @override String get credibilityScore => 'Credibility Score';
  @override String get credibilitySubtitle => '0–100 trust rating for scouts';
  @override String get credibilityExplain => 'Your score reflects approved drills, match ratings, certifications, and match participation.';
  @override String get factorDrills => 'Drill scores & completions';
  @override String get factorRatings => 'Post-match peer ratings';
  @override String get factorCerts => 'Certifications earned';
  @override String get factorParticipation => 'Match participation';
  @override String get factorVideoRatings => 'Video ratings';

  @override String get findPlayersTitle => 'Find Players';
  @override String get scoutAssistTooltip => 'AI Scout Assistant';
  @override String get searchByPlayer => 'Search by player name...';
  @override String get allCities => 'All cities';
  @override String get searchBtn => 'Search';
  @override String get resetBtn => 'Reset';
  @override String get noPlayersMatch => 'No players match your filters';
  @override String get certifications => 'Certifications';

  @override String get leaderboardTitle => 'Leaderboard';
  @override String get mostMatches => 'Most Matches';
  @override String get mostBadges => 'Most Badges';
  @override String get bestRated => 'Best Rated';
  @override String get noPlayersRanked => 'No players ranked yet';
  @override String get filterByPosition => 'Position';
  @override String get filterByAgeGroup => 'Age group';
  @override String get allPositions => 'All positions';
  @override String get allAgeGroups => 'All ages';
  @override String get ageGroupU18 => 'U18';
  @override String get ageGroupU21 => 'U21';
  @override String get ageGroupOpen => 'Open';
  @override String get listView => 'List';
  @override String get mapView => 'Map';
  @override String scoutNotesTitle(String playerName) => 'Private notes — $playerName';
  @override String get privateNotes => 'Private notes';
  @override String get noNotesYet => 'No notes yet';
  @override String get technicalAbility => 'Technical ability (1-5)';
  @override String get potential => 'Potential (1-5)';
  @override String get scoutNoteLabel => 'Scout note';
  @override String get saveNote => 'Save note';
  @override String get deleteNote => 'Delete note';
  @override String get scoutNoteSaved => 'Note saved';
  @override String get scoutNoteDeleted => 'Note deleted';
  @override String get scoutNoteInvalid => 'Enter ratings 1-5 and a note';

  @override String get adminHome => 'Home';
  @override String get adminVenues => 'Venues';
  @override String get adminDrills => 'Drills';
  @override String get adminCourses => 'Courses';
  @override String get adminManage => 'Manage';

  @override String get adminDashboard => 'Admin Dashboard';
  @override String get statPlayers => 'Players';
  @override String get statPendingDrills => 'Pending drills';
  @override String get statActiveMatches => 'Active matches';
  @override String get statFlaggedPosts => 'Flagged posts';
  @override String get statTotalUsers => 'Total users';
  @override String get quickActions => 'Quick actions';
  @override String get addVenue => 'Add venue';
  @override String get reviewDrills => 'Review drills';
  @override String get generateCourse => 'Generate course';
  @override String get moderatePosts => 'Moderate posts';

  @override String get venues => 'Venues';
  @override String get createVenue => 'Create venue';
  @override String get editVenue => 'Edit venue';
  @override String get name => 'Name';
  @override String get address => 'Address';
  @override String get phoneNumber => 'Phone number';
  @override String get description => 'Description';
  @override String get pricePerHourMad => 'Price per hour (MAD)';
  @override String get numberOfPitches => 'Number of pitches';
  @override String get openTime => 'Open time (HH:mm)';
  @override String get closeTime => 'Close time (HH:mm)';
  @override String get grassType => 'Grass type';
  @override String get natural => 'Natural';
  @override String get artificial => 'Artificial';
  @override String get hybrid => 'Hybrid';
  @override String get pitchTypes => 'Pitch types';
  @override String get nameAddressRequired => 'Name and address are required';
  @override String get selectOneFormat => 'Select at least one format';
  @override String get venueCreated => 'Venue created';
  @override String get venueUpdated => 'Venue updated';
  @override String get edit => 'Edit';
  @override String get mapLocation => 'Map location';
  @override String get tapMapToPin => 'Tap the map to drop a pin';

  @override String get drills => 'Drills';
  @override String get submissions => 'Submissions';
  @override String get drillLibrary => 'Drill library';
  @override String get noPendingSubmissions => 'No pending submissions';
  @override String get scoreIfApproving => 'Score (if approving)';
  @override String get approve => 'Approve';
  @override String get reject => 'Reject';
  @override String get createDrill => 'Create drill';
  @override String get title => 'Title';
  @override String get progressionOrder => 'Progression order';
  @override String get saveDrill => 'Save drill';

  @override String get courses => 'Courses';
  @override String get aiPlusCreate => 'AI + Create';
  @override String get noMediaAttached => 'No media attached';
  @override String get lessonMediaUploaded => 'Lesson media uploaded';
  @override String get deleteCourse => 'Delete course';
  @override String get createCourseManually => 'Create course manually';
  @override String get publishCourse => 'Publish course';
  @override String get coursePublished => 'Course published';
  @override String get courseLevel => 'Level';
  @override String get addLesson => 'Add lesson';
  @override String get lessonContent => 'Lesson content';
  @override String get finalLessonQuiz => 'Final lesson quiz';
  @override String get addQuestion => 'Add question';
  @override String get completeFinalQuiz => 'Complete the final lesson quiz';
  @override String get attachMedia => 'Attach media';
  @override String get chooseImageOrVideo => 'Image or video';
  @override String get chooseDocument => 'Document';
  @override String optionN(int n) => 'Option $n';

  @override String get manage => 'Manage';
  @override String get users => 'Users';
  @override String get posts => 'Posts';
  @override String get active => 'Active';
  @override String get banned => 'Banned';
  @override String get agentPendingVerification => 'Agent pending verification';
  @override String get ban => 'Ban';
  @override String get unban => 'Unban';
  @override String get verifyAgent => 'Verify agent';
  @override String get agentVerified => 'Agent verified';
  @override String get flaggedOnly => 'Flagged only';
  @override String get flag => 'Flag';
  @override String get unflag => 'Unflag';
  @override String get remove => 'Remove';
  @override String get postRemoved => 'Post removed';

  @override String get generateCourseTitle => 'Generate Course';
  @override String get generateCourseSubtitle => 'Generate lessons and a final quiz with AI, then publish the course.';
  @override String get courseTitle => 'Course title';
  @override String get briefDescription => 'Brief description';
  @override String get titleRequired => 'Title required';
  @override String get descriptionRequired => 'Description required';
  @override String get generateWithAi => 'Generate with AI';
  @override String get quizQuestions => 'quiz questions';

  @override String get language => 'Language';
  @override String get english => 'English';
  @override String get french => 'Français';

  @override String get announcements => 'Trials & News';
  @override String get noAnnouncementsYet => 'No announcements yet';
  @override String get createAnnouncement => 'Create announcement';
  @override String get announcementType => 'Type';
  @override String get official => 'Official';

  @override String get notifications => 'Notifications';
  @override String get noNotificationsYet => 'No notifications yet';
  @override String get markAllRead => 'Mark all read';

  @override String get mySquads => 'My Squads';
  @override String get createSquad => 'Create Squad';
  @override String get noSquadsYet => 'No squads yet.\nCreate one to play with friends.';
  @override String get squadName => 'Squad name';
  @override String get squadNameHint => 'Friday Night FC';
  @override String get squadCreated => 'Squad created';
  @override String get captain => 'Captain';
  @override String get inviteToSquad => 'Invite to Squad';
  @override String get noCaptainSquads => 'Create a squad first to invite players';
  @override String get playerInvitedToSquad => 'Player invited to squad';
  @override String get joinSquads => 'Join Squads';
  @override String get joinRequestPending => 'Request pending';
  @override String get alreadyInSquad => 'Already in squad';
  @override String get incomingJoinRequests => 'Join Requests';
  @override String get noSquadsInCity => 'No squads in this city yet';

  @override String get clubsAndAcademies => 'Clubs & Academies';
  @override String get clubsDescription => 'Browse football clubs and academies near you.';
  @override String get noClubsYet => 'No clubs listed yet';
  @override String get browseClubs => 'Clubs';

  @override String get referralCode => 'Referral Code';
  @override String get referralCodeOptional => 'Referral code (optional)';
  @override String get referralCodeHint => 'Enter a friend\'s code';
  @override String get referralCodeCopied => 'Referral code copied';
  @override String get copyCode => 'Copy code';

  @override String get playersNearby => 'Players nearby';
  @override String get openMatches => 'Open matches';
  @override String get upcomingMatches => 'Upcoming matches';
  @override String get topPlayers => 'Top players';

  @override String get weeklyChallenge => 'Weekly Challenge';
  @override String get noActiveChallenge => 'No active challenge right now. Check back soon!';
  @override String get submitChallenge => 'Submit to Challenge';
  @override String get challengeSubmissions => 'Submissions';
  @override String get vote => 'Vote';
  @override String get videoUrl => 'Video URL';
  @override String get videoUrlHint => 'https://...';
  @override String get challengeSubmitted => 'Challenge submission sent!';
  @override String get votes => 'votes';

  @override String get comparePlayers => 'Compare Players';
  @override String get compareMode => 'Compare';
  @override String get selectTwoPlayers => 'Select two bookmarked players to compare';
  @override String get playerA => 'Player A';
  @override String get playerB => 'Player B';
  @override String get compare => 'Compare';

  @override String get timeline => 'Timeline';
  @override String get noTimelineEvents => 'No activity yet';

  @override String get agent => 'Agent';
  @override String get agentHome => 'Agent Home';
  @override String get navTrials => 'Trials';
  @override String get navMessages => 'Messages';
  @override String get agentAccountCreated => 'Agent account created. Awaiting admin verification.';
  @override String get noConversationsYet => 'No conversations yet';
  @override String get typeMessage => 'Type a message...';
  @override String get send => 'Send';
  @override String get sendMessage => 'Message';
  @override String get you => 'You';
  @override String get confirmDeletePost => 'Delete this post? This cannot be undone.';
  @override String get confirmDeleteTrial => 'Delete this trial? This cannot be undone.';

  @override String get analyzeWithAi => 'Analyze with AI';
  @override String get aiNoResult => 'No analysis was returned. Tap refresh to try again.';
  @override String get videoScoutingReport => 'Video Scouting Report';

  @override String get noDrillsInLevel => 'No drills in this level yet.';
  @override String get noChallengeSubmissions => 'No submissions yet. Be the first to enter!';
  @override String get noMessagesYet => 'No messages yet. Say hello!';

  @override String positionLabel(PlayerPosition position) => switch (position) {
        PlayerPosition.striker => 'Striker',
        PlayerPosition.midfielder => 'Midfielder',
        PlayerPosition.defender => 'Defender',
        PlayerPosition.goalkeeper => 'Goalkeeper',
      };

  @override String preferredFootLabel(PreferredFoot foot) => switch (foot) {
        PreferredFoot.left => 'Left',
        PreferredFoot.right => 'Right',
        PreferredFoot.both => 'Both',
      };

  @override String matchGenderLabel(MatchGender gender) => switch (gender) {
        MatchGender.maleOnly => menOnly,
        MatchGender.femaleOnly => womenOnly,
        MatchGender.mixed => mixed,
      };

  @override String drillLevelLabel(DrillLevel level) => switch (level) {
        DrillLevel.beginner => beginner,
        DrillLevel.intermediate => intermediate,
        DrillLevel.advanced => advanced,
      };

  @override String targetSkillLabel(TargetSkill skill) => switch (skill) {
        TargetSkill.dribbling => dribbling,
        TargetSkill.shooting => shooting,
        TargetSkill.passing => passing,
        TargetSkill.speed => speed,
        TargetSkill.heading => heading,
        TargetSkill.stamina => stamina,
      };

  @override String announcementTypeLabel(AnnouncementType type) => switch (type) {
        AnnouncementType.trial => 'Trial',
        AnnouncementType.news => 'News',
        AnnouncementType.tournament => 'Tournament',
        AnnouncementType.officialTrial => 'Official trial',
      };

  @override String nYearsOld(int n) => '$n yrs';
  @override String nDrillsAndCerts(int drills, int certs) => '$drills drills · $certs certs';
  @override String avgDrillScore(String score) => 'Avg drill: $score';
}

class _TrFr extends Tr {
  const _TrFr();

  @override String get appName => 'KickPro';
  @override String get retry => 'Réessayer';
  @override String get cancel => 'Annuler';
  @override String get save => 'Enregistrer';
  @override String get delete => 'Supprimer';
  @override String get search => 'Rechercher';
  @override String get loading => 'Chargement...';
  @override String get none => 'Aucun';

  @override String get loginTagline => 'Votre CV footballistique digital';
  @override String get email => 'E-mail';
  @override String get emailHint => 'vous@exemple.com';
  @override String get password => 'Mot de passe';
  @override String get passwordHint => '••••••••';
  @override String get passwordMinHint => 'Min. 8 caractères';
  @override String get signIn => 'Se connecter';
  @override String get newHereCreate => 'Nouveau ? Créer un compte';
  @override String get trustedBy => 'Utilisé par les joueurs et les scouts à travers le Maroc';
  @override String get createAccount => 'Créer un compte';
  @override String get joinKickpro => 'Rejoignez KickPro en tant que joueur ou scout';
  @override String get iAmA => 'Je suis';
  @override String get player => 'Joueur';
  @override String get scout => 'Scout';
  @override String get scoutAccountCreated => 'Compte scout créé';

  @override String get geminiRateLimit => 'Limite Gemini atteinte. Attendez 1–2 minutes et réessayez.';
  @override String get aiTimeout => "L'IA a expiré. Gemini est peut-être limité — attendez et réessayez.";
  @override String get cannotReachServer => 'Impossible de joindre le serveur. Vérifiez que Docker est lancé.';

  @override String get navFeed => 'Fil';
  @override String get navDrills => 'Exercices';
  @override String get navPost => 'Publier';
  @override String get navMatches => 'Matchs';
  @override String get navProfile => 'Profil';
  @override String get navSearch => 'Recherche';
  @override String get navBookmarks => 'Favoris';
  @override String get navVideos => 'Vidéos';
  @override String get bookmarks => 'Favoris';
  @override String get noBookmarksYet => 'Aucun joueur en favoris.\nAppuyez sur l\'icône favoris pour enregistrer un joueur.';

  @override String get buildProfile => 'Créer votre profil';
  @override String get tellScouts => 'Montrez aux scouts qui vous êtes sur le terrain';
  @override String get fullName => 'Nom complet';
  @override String get fullNameHint => 'Youssef Benali';
  @override String get dateOfBirth => 'Date de naissance';
  @override String get selectDate => 'Choisir une date';
  @override String get city => 'Ville';
  @override String get cityHint => 'Casablanca';
  @override String get position => 'Poste';
  @override String get preferredFoot => 'Pied préféré';
  @override String get heightCm => 'Taille (cm)';
  @override String get weightKg => 'Poids (kg)';
  @override String get bioOptional => 'Bio (optionnel)';
  @override String get bioHint => 'Ailier rapide de Casablanca...';
  @override String get continueToSkills => 'Continuer vers les compétences';
  @override String get selectDob => 'Veuillez sélectionner votre date de naissance';

  @override String get rateSkills => 'Évaluez vos compétences';
  @override String get dragSlider => 'Glissez chaque curseur de 1 à 10 étoiles';
  @override String get saveAndView => 'Enregistrer et voir le profil';

  @override String get dribbling => 'Dribble';
  @override String get shooting => 'Tir';
  @override String get passing => 'Passe';
  @override String get speed => 'Vitesse';
  @override String get heading => 'Jeu de tête';
  @override String get stamina => 'Endurance';
  @override String get strengths => 'Points forts';
  @override String get weaknesses => 'Points faibles';

  @override String get myProfile => 'Mon profil';
  @override String get editProfileTooltip => 'Modifier le profil';
  @override String get skills => 'Compétences';
  @override String get certs => 'Certifs';
  @override String get score => 'Score';
  @override String get overview => 'Aperçu';
  @override String get browseCourses => 'Parcourir les cours';
  @override String get noCertsYet => 'Pas encore de certifications. Terminez un quiz de cours pour obtenir votre premier badge.';
  @override String get height => 'Taille';
  @override String get weight => 'Poids';
  @override String get born => 'Né(e)';
  @override String get bio => 'Bio';
  @override String get followers => 'Abonnés';
  @override String get following => 'Abonnements';
  @override String get follow => 'Suivre';
  @override String get currentlyRecovering => 'En convalescence';
  @override String get injuryStatus => 'Statut de blessure';
  @override String get injuryStatusSubtitle => 'Indiquez que vous êtes en convalescence pour suspendre les matchs';
  @override String get shareProfile => 'Partager le profil';
  @override String get profileQrTitle => 'QR code du profil';
  @override String get cannotJoinWhileInjured => 'Vous ne pouvez pas rejoindre un match en convalescence';

  @override String get editProfile => 'Modifier le profil';
  @override String get skillRatings => 'Évaluation des compétences';
  @override String get saveChanges => 'Enregistrer les modifications';
  @override String get completeAllFields => 'Remplissez tous les champs requis';
  @override String get profileUpdated => 'Profil mis à jour';

  @override String get viewProfilePicture => 'Voir la photo de profil';
  @override String get editProfilePicture => 'Modifier la photo de profil';
  @override String get deleteProfilePicture => 'Supprimer la photo de profil';
  @override String get adjustPhoto => 'Ajuster la photo';
  @override String get couldNotLoadPhoto => 'Impossible de charger la photo';
  @override String get deletePhotoTitle => 'Supprimer la photo de profil ?';
  @override String get deletePhotoBody => 'Votre photo de profil sera supprimée.';
  @override String get profilePhotoUpdated => 'Photo de profil mise à jour';
  @override String get profilePhotoDeleted => 'Photo de profil supprimée';

  @override String get feed => 'Fil';
  @override String get noPostsYet => 'Pas encore de publications. Appuyez sur + pour partager.';
  @override String get editPost => 'Modifier la publication';
  @override String get caption => 'Légende';
  @override String get skillTagOptional => 'Tag compétence (optionnel)';
  @override String get share => 'Partager';

  @override String get createPost => 'Créer une publication';
  @override String get text => 'Texte';
  @override String get photo => 'Photo';
  @override String get video => 'Vidéo';
  @override String get captionHintText => 'Partagez une pensée avec l\'équipe...';
  @override String get captionHintMedia => 'Décrivez votre publication...';
  @override String get post => 'Publier';
  @override String get pickPhotoPost => 'Choisir photo et publier';
  @override String get pickVideoPost => 'Choisir vidéo et publier';
  @override String get writeSomethingFirst => 'Écrivez quelque chose d\'abord';
  @override String get postShared => 'Publication partagée';

  @override String get comments => 'Commentaires';
  @override String get noCommentsYet => 'Pas encore de commentaires';
  @override String get commentLabel => 'Commentaire';
  @override String get addCommentHint => 'Ajouter un commentaire...';

  @override String get drillProgression => 'Progression exercices';
  @override String get leaderboard => 'Classement';
  @override String get aiCoach => 'Coach IA';
  @override String get completed => 'Terminé';
  @override String get current => 'En cours';
  @override String get locked => 'Verrouillé';
  @override String get submitDrillVideo => 'Soumettre la vidéo';
  @override String get rules => 'Règles';
  @override String get noVideoSelected => 'Aucune vidéo sélectionnée';
  @override String get videoReady => 'Vidéo prête à soumettre';
  @override String get recordPickVideo => 'Enregistrer / Choisir une vidéo';
  @override String get changeVideo => 'Changer la vidéo';
  @override String get submitForReview => 'Soumettre pour révision';
  @override String get selectVideoFirst => 'Sélectionnez d\'abord une vidéo';
  @override String get submittedForReview => 'Soumis pour révision admin';

  @override String get beginner => 'Débutant';
  @override String get intermediate => 'Intermédiaire';
  @override String get advanced => 'Avancé';

  @override String get bookMatch => 'Réserver un match';
  @override String get matches => 'Matchs';
  @override String get open => 'Ouverts';
  @override String get myMatches => 'Mes matchs';
  @override String get noOpenMatches => 'Pas encore de matchs ouverts.\nSoyez le premier à en créer un !';
  @override String get noMyMatches => 'Vous n\'avez pas encore de matchs.\nAppuyez sur Réserver pour en créer un.';

  @override String get statusOpen => 'OUVERT';
  @override String get statusFull => 'COMPLET';
  @override String get statusDone => 'TERMINÉ';
  @override String get statusCancelled => 'ANNULÉ';

  @override String get chooseCity => 'Choisir la ville';
  @override String get chooseStadium => 'Choisir le stade';
  @override String get pickDateTime => 'Choisir date et heure';
  @override String get matchDetails => 'Détails du match';
  @override String get continueBtn => 'Continuer';
  @override String get confirmBooking => 'Confirmer la réservation';
  @override String get completeBookingSteps => 'Complétez toutes les étapes';
  @override String get matchBooked => 'Match réservé !';
  @override String get selectACity => 'Sélectionnez une ville';
  @override String get selectAStadium => 'Sélectionnez un stade';
  @override String get selectTimeSlot => 'Sélectionnez un créneau horaire';
  @override String get wherePlay => 'Où voulez-vous jouer ?';
  @override String get searchByName => 'Rechercher par nom';
  @override String get noStadiumsFound => 'Aucun stade trouvé';
  @override String get allowedFormats => 'Formats autorisés';
  @override String get photos => 'Photos';
  @override String get selectADate => 'Choisir une date';
  @override String get availableSlots => 'Créneaux disponibles';
  @override String get pickDateToSeeSlots => 'Choisissez une date pour voir les créneaux';
  @override String get noSlotsForDate => 'Aucun créneau pour cette date';
  @override String get matchFormat => 'Format du match';
  @override String get ageRange => 'Tranche d\'âge';
  @override String get gender => 'Genre';

  @override String get menOnly => 'Hommes uniquement';
  @override String get womenOnly => 'Femmes uniquement';
  @override String get mixed => 'Mixte';

  @override String get matchDetailsTitle => 'Détails du match';
  @override String get players => 'Joueurs';
  @override String get requestToJoin => 'Demander à rejoindre';
  @override String get markCompleted => 'Marquer comme terminé';
  @override String get cancelMatch => 'Annuler le match';
  @override String get openChat => 'Ouvrir le chat';
  @override String get ratePlayers => 'Évaluer les joueurs';
  @override String get joinPending => 'Votre demande est en attente d\'approbation.';
  @override String get cancelMatchTitle => 'Annuler le match ?';
  @override String get cancelMatchBody => 'Cette action est irréversible.';
  @override String get keep => 'Garder';
  @override String get cancelMatchBtn => 'Annuler le match';
  @override String get joinRequestSent => 'Demande envoyée';
  @override String get matchCompletedToast => 'Match terminé — évaluez vos coéquipiers !';
  @override String get matchCancelledToast => 'Match annulé';
  @override String get approved => 'Approuvé';
  @override String get pending => 'En attente';
  @override String get rejected => 'Refusé';

  @override String get matchChat => 'Chat du match';
  @override String get noChatMessages => 'Pas encore de messages.\nDites bonjour à vos coéquipiers !';
  @override String get messageTeamHint => 'Envoyez un message...';

  @override String get ratePlayersTitle => 'Évaluer les joueurs';
  @override String get howDidPerform => 'Comment vos coéquipiers ont-ils joué ?';
  @override String get rateInstructions => 'Évaluez la performance, la ponctualité, le travail d\'équipe et le comportement (1–5).';
  @override String get performance => 'Performance';
  @override String get punctuality => 'Ponctualité';
  @override String get teamwork => 'Travail d\'équipe';
  @override String get behavior => 'Comportement';
  @override String get submitRating => 'Soumettre l\'évaluation';
  @override String get submittedRatings => 'Évaluations soumises';
  @override String get selectPlayerToRate => 'Sélectionnez un joueur à évaluer';
  @override String get ratingSubmitted => 'Évaluation soumise';

  @override String get certificationCourses => 'Cours de certification';
  @override String get courseDescription => 'Terminez les leçons et réussissez le quiz final pour obtenir des badges qui renforcent votre crédibilité.';
  @override String get noCoursesYet => 'Pas encore de cours disponibles';
  @override String get certified => 'Certifié';
  @override String get comingSoon => 'Bientôt disponible';
  @override String get course => 'Cours';
  @override String get youEarnedCert => 'Vous avez obtenu cette certification !';
  @override String get lessons => 'Leçons';
  @override String get tapLessonToRead => 'Appuyez sur une leçon pour lire le contenu complet.';
  @override String get noLessonsYet => 'Ce cours n\'a pas encore de leçons. Un administrateur doit ajouter du contenu.';
  @override String get quiz => 'Quiz';
  @override String get tapToReadLesson => 'Appuyez pour lire la leçon';
  @override String get takeFinalQuiz => 'Passer le quiz final';
  @override String get finalQuizLesson => 'Leçon quiz final';

  @override String get courseQuiz => 'Quiz du cours';
  @override String get submitQuiz => 'Soumettre le quiz';
  @override String get quizResult => 'Résultat du quiz';
  @override String get quizPassed => 'Quiz réussi !';
  @override String get keepPractising => 'Continuez à pratiquer';
  @override String get certificationEarned => 'Certification obtenue';
  @override String get backToCourse => 'Retour au cours';
  @override String get answerAllQuestions => 'Veuillez répondre à toutes les questions';

  @override String get aiCoachTitle => 'Coach IA';
  @override String get aiCoachSubtitle => 'Coaching football personnalisé propulsé par Gemini.';
  @override String get drillRecommendations => 'Exercices recommandés';
  @override String get drillRecommendationsDesc => 'Exercices adaptés à votre profil';
  @override String get mealPlan => 'Plan nutritionnel';
  @override String get mealPlanDesc => 'Nutrition spécifique au football pour votre poste';
  @override String get recoveryPlan => 'Plan de récupération';
  @override String get recoveryPlanDesc => 'Conseils de retour au jeu après une blessure';
  @override String get recommendedDrills => 'Exercices recommandés';
  @override String get noDrillRecommendations => 'Pas de recommandations pour le moment. Complétez d\'abord votre profil.';
  @override String get recoveryPlanTitle => 'Plan de récupération';
  @override String get recoveryPlanSubtitle => 'Décrivez votre blessure pour des conseils de récupération.';
  @override String get injuryType => 'Type de blessure';
  @override String get injuryTypeHint => 'ex. élongation, entorse';
  @override String get bodyPart => 'Partie du corps';
  @override String get bodyPartHint => 'ex. ischio-jambiers, cheville';
  @override String get severity => 'Gravité';
  @override String get severityHint => 'légère, modérée ou sévère';
  @override String get required => 'Requis';
  @override String get generatePlan => 'Générer le plan';
  @override String get scoreExplanation => 'Explication du score';
  @override String get scoutAssistant => 'Assistant IA Scout';
  @override String get scoutAssistSubtitle => 'Décrivez le profil de joueur que vous recherchez.';
  @override String get scoutAssistHint => 'ex. Attaquants rapides à Casablanca avec bon dribble';
  @override String get findPlayers => 'Trouver des joueurs';
  @override String get describeWhatLookingFor => 'Décrivez ce que vous recherchez';
  @override String get explainWithAi => 'Expliquer avec l\'IA';

  @override String get credibilityScore => 'Score de crédibilité';
  @override String get credibilitySubtitle => 'Note de confiance 0–100 pour les scouts';
  @override String get credibilityExplain => 'Votre score reflète les exercices approuvés, les évaluations de matchs, les certifications et la participation.';
  @override String get factorDrills => 'Scores et exercices complétés';
  @override String get factorRatings => 'Évaluations post-match';
  @override String get factorCerts => 'Certifications obtenues';
  @override String get factorParticipation => 'Participation aux matchs';
  @override String get factorVideoRatings => 'Évaluations vidéo';

  @override String get findPlayersTitle => 'Trouver des joueurs';
  @override String get scoutAssistTooltip => 'Assistant IA Scout';
  @override String get searchByPlayer => 'Rechercher par nom de joueur...';
  @override String get allCities => 'Toutes les villes';
  @override String get searchBtn => 'Rechercher';
  @override String get resetBtn => 'Réinitialiser';
  @override String get noPlayersMatch => 'Aucun joueur ne correspond à vos filtres';
  @override String get certifications => 'Certifications';

  @override String get leaderboardTitle => 'Classement';
  @override String get mostMatches => 'Plus de matchs';
  @override String get mostBadges => 'Plus de badges';
  @override String get bestRated => 'Mieux notés';
  @override String get noPlayersRanked => 'Aucun joueur classé pour le moment';
  @override String get filterByPosition => 'Poste';
  @override String get filterByAgeGroup => 'Catégorie d\'âge';
  @override String get allPositions => 'Tous les postes';
  @override String get allAgeGroups => 'Tous les âges';
  @override String get ageGroupU18 => 'U18';
  @override String get ageGroupU21 => 'U21';
  @override String get ageGroupOpen => 'Open';
  @override String get listView => 'Liste';
  @override String get mapView => 'Carte';
  @override String scoutNotesTitle(String playerName) => 'Notes privées — $playerName';
  @override String get privateNotes => 'Notes privées';
  @override String get noNotesYet => 'Aucune note pour le moment';
  @override String get technicalAbility => 'Capacité technique (1-5)';
  @override String get potential => 'Potentiel (1-5)';
  @override String get scoutNoteLabel => 'Note scout';
  @override String get saveNote => 'Enregistrer la note';
  @override String get deleteNote => 'Supprimer la note';
  @override String get scoutNoteSaved => 'Note enregistrée';
  @override String get scoutNoteDeleted => 'Note supprimée';
  @override String get scoutNoteInvalid => 'Entrez des notes de 1 à 5 et un commentaire';

  @override String get adminHome => 'Accueil';
  @override String get adminVenues => 'Terrains';
  @override String get adminDrills => 'Exercices';
  @override String get adminCourses => 'Cours';
  @override String get adminManage => 'Gérer';

  @override String get adminDashboard => 'Tableau de bord admin';
  @override String get statPlayers => 'Joueurs';
  @override String get statPendingDrills => 'Exercices en attente';
  @override String get statActiveMatches => 'Matchs actifs';
  @override String get statFlaggedPosts => 'Publications signalées';
  @override String get statTotalUsers => 'Utilisateurs totaux';
  @override String get quickActions => 'Actions rapides';
  @override String get addVenue => 'Ajouter un terrain';
  @override String get reviewDrills => 'Réviser les exercices';
  @override String get generateCourse => 'Générer un cours';
  @override String get moderatePosts => 'Modérer les publications';

  @override String get venues => 'Terrains';
  @override String get createVenue => 'Créer un terrain';
  @override String get editVenue => 'Modifier le terrain';
  @override String get name => 'Nom';
  @override String get address => 'Adresse';
  @override String get phoneNumber => 'Numéro de téléphone';
  @override String get description => 'Description';
  @override String get pricePerHourMad => 'Prix par heure (MAD)';
  @override String get numberOfPitches => 'Nombre de terrains';
  @override String get openTime => 'Heure d\'ouverture (HH:mm)';
  @override String get closeTime => 'Heure de fermeture (HH:mm)';
  @override String get grassType => 'Type de gazon';
  @override String get natural => 'Naturel';
  @override String get artificial => 'Artificiel';
  @override String get hybrid => 'Hybride';
  @override String get pitchTypes => 'Types de terrains';
  @override String get nameAddressRequired => 'Le nom et l\'adresse sont requis';
  @override String get selectOneFormat => 'Sélectionnez au moins un format';
  @override String get venueCreated => 'Terrain créé';
  @override String get venueUpdated => 'Terrain mis à jour';
  @override String get edit => 'Modifier';
  @override String get mapLocation => 'Emplacement sur la carte';
  @override String get tapMapToPin => 'Appuyez sur la carte pour placer un marqueur';

  @override String get drills => 'Exercices';
  @override String get submissions => 'Soumissions';
  @override String get drillLibrary => 'Bibliothèque d\'exercices';
  @override String get noPendingSubmissions => 'Aucune soumission en attente';
  @override String get scoreIfApproving => 'Score (si approuvé)';
  @override String get approve => 'Approuver';
  @override String get reject => 'Rejeter';
  @override String get createDrill => 'Créer un exercice';
  @override String get title => 'Titre';
  @override String get progressionOrder => 'Ordre de progression';
  @override String get saveDrill => 'Enregistrer l\'exercice';

  @override String get courses => 'Cours';
  @override String get aiPlusCreate => 'IA + Créer';
  @override String get noMediaAttached => 'Aucun média attaché';
  @override String get lessonMediaUploaded => 'Média de leçon envoyé';
  @override String get deleteCourse => 'Supprimer le cours';
  @override String get createCourseManually => 'Créer un cours manuellement';
  @override String get publishCourse => 'Publier le cours';
  @override String get coursePublished => 'Cours publié';
  @override String get courseLevel => 'Niveau';
  @override String get addLesson => 'Ajouter une leçon';
  @override String get lessonContent => 'Contenu de la leçon';
  @override String get finalLessonQuiz => 'Quiz de la dernière leçon';
  @override String get addQuestion => 'Ajouter une question';
  @override String get completeFinalQuiz => 'Complétez le quiz de la dernière leçon';
  @override String get attachMedia => 'Joindre un média';
  @override String get chooseImageOrVideo => 'Image ou vidéo';
  @override String get chooseDocument => 'Document';
  @override String optionN(int n) => 'Option $n';

  @override String get manage => 'Gérer';
  @override String get users => 'Utilisateurs';
  @override String get posts => 'Publications';
  @override String get active => 'Actif';
  @override String get banned => 'Banni';
  @override String get agentPendingVerification => 'Agent en attente de vérification';
  @override String get ban => 'Bannir';
  @override String get unban => 'Débannir';
  @override String get verifyAgent => 'Vérifier l\'agent';
  @override String get agentVerified => 'Agent vérifié';
  @override String get flaggedOnly => 'Signalés uniquement';
  @override String get flag => 'Signaler';
  @override String get unflag => 'Retirer le signalement';
  @override String get remove => 'Supprimer';
  @override String get postRemoved => 'Publication supprimée';

  @override String get generateCourseTitle => 'Générer un cours';
  @override String get generateCourseSubtitle => 'Générez des leçons et un quiz final avec l\'IA, puis publiez le cours.';
  @override String get courseTitle => 'Titre du cours';
  @override String get briefDescription => 'Brève description';
  @override String get titleRequired => 'Titre requis';
  @override String get descriptionRequired => 'Description requise';
  @override String get generateWithAi => 'Générer avec l\'IA';
  @override String get quizQuestions => 'questions de quiz';

  @override String get language => 'Langue';
  @override String get english => 'English';
  @override String get french => 'Français';

  @override String get announcements => 'Essais & Actualités';
  @override String get noAnnouncementsYet => 'Pas encore d\'annonces';
  @override String get createAnnouncement => 'Créer une annonce';
  @override String get announcementType => 'Type';
  @override String get official => 'Officiel';

  @override String get notifications => 'Notifications';
  @override String get noNotificationsYet => 'Pas encore de notifications';
  @override String get markAllRead => 'Tout marquer lu';

  @override String get mySquads => 'Mes équipes';
  @override String get createSquad => 'Créer une équipe';
  @override String get noSquadsYet => 'Pas encore d\'équipe.\nCréez-en une pour jouer entre amis.';
  @override String get squadName => 'Nom de l\'équipe';
  @override String get squadNameHint => 'FC Vendredi Soir';
  @override String get squadCreated => 'Équipe créée';
  @override String get captain => 'Capitaine';
  @override String get inviteToSquad => 'Inviter dans l\'équipe';
  @override String get noCaptainSquads => 'Créez d\'abord une équipe pour inviter des joueurs';
  @override String get playerInvitedToSquad => 'Joueur invité dans l\'équipe';
  @override String get joinSquads => 'Rejoindre une équipe';
  @override String get joinRequestPending => 'Demande en attente';
  @override String get alreadyInSquad => 'Déjà dans l\'équipe';
  @override String get incomingJoinRequests => 'Demandes d\'adhésion';
  @override String get noSquadsInCity => 'Aucune équipe dans cette ville pour le moment';

  @override String get clubsAndAcademies => 'Clubs & Académies';
  @override String get clubsDescription => 'Parcourez les clubs et académies de football près de chez vous.';
  @override String get noClubsYet => 'Pas encore de clubs';
  @override String get browseClubs => 'Clubs';

  @override String get referralCode => 'Code de parrainage';
  @override String get referralCodeOptional => 'Code de parrainage (optionnel)';
  @override String get referralCodeHint => 'Entrez le code d\'un ami';
  @override String get referralCodeCopied => 'Code copié';
  @override String get copyCode => 'Copier le code';

  @override String get playersNearby => 'Joueurs à proximité';
  @override String get openMatches => 'Matchs ouverts';
  @override String get upcomingMatches => 'Matchs à venir';
  @override String get topPlayers => 'Meilleurs joueurs';

  @override String get weeklyChallenge => 'Défi hebdomadaire';
  @override String get noActiveChallenge => 'Aucun défi actif pour le moment. Revenez bientôt !';
  @override String get submitChallenge => 'Participer au défi';
  @override String get challengeSubmissions => 'Soumissions';
  @override String get vote => 'Voter';
  @override String get videoUrl => 'URL vidéo';
  @override String get videoUrlHint => 'https://...';
  @override String get challengeSubmitted => 'Soumission envoyée !';
  @override String get votes => 'votes';

  @override String get comparePlayers => 'Comparer les joueurs';
  @override String get compareMode => 'Comparer';
  @override String get selectTwoPlayers => 'Sélectionnez deux joueurs favoris à comparer';
  @override String get playerA => 'Joueur A';
  @override String get playerB => 'Joueur B';
  @override String get compare => 'Comparer';

  @override String get timeline => 'Historique';
  @override String get noTimelineEvents => 'Aucune activité pour le moment';

  @override String get agent => 'Agent';
  @override String get agentHome => 'Accueil agent';
  @override String get navTrials => 'Essais';
  @override String get navMessages => 'Messages';
  @override String get agentAccountCreated => 'Compte agent créé. En attente de vérification admin.';
  @override String get noConversationsYet => 'Aucune conversation pour le moment';
  @override String get typeMessage => 'Écrire un message...';
  @override String get send => 'Envoyer';
  @override String get sendMessage => 'Message';
  @override String get you => 'Vous';
  @override String get confirmDeletePost => 'Supprimer cette publication ? Cette action est irréversible.';
  @override String get confirmDeleteTrial => 'Supprimer cet essai ? Cette action est irréversible.';

  @override String get analyzeWithAi => 'Analyser avec l\'IA';
  @override String get aiNoResult => 'Aucune analyse retournée. Appuyez sur actualiser pour réessayer.';
  @override String get videoScoutingReport => 'Rapport de scouting vidéo';

  @override String get noDrillsInLevel => 'Aucun exercice dans ce niveau pour le moment.';
  @override String get noChallengeSubmissions => 'Aucune soumission pour le moment. Soyez le premier !';
  @override String get noMessagesYet => 'Aucun message pour le moment. Dites bonjour !';

  @override String positionLabel(PlayerPosition position) => switch (position) {
        PlayerPosition.striker => 'Attaquant',
        PlayerPosition.midfielder => 'Milieu',
        PlayerPosition.defender => 'Défenseur',
        PlayerPosition.goalkeeper => 'Gardien',
      };

  @override String preferredFootLabel(PreferredFoot foot) => switch (foot) {
        PreferredFoot.left => 'Gauche',
        PreferredFoot.right => 'Droit',
        PreferredFoot.both => 'Les deux',
      };

  @override String matchGenderLabel(MatchGender gender) => switch (gender) {
        MatchGender.maleOnly => menOnly,
        MatchGender.femaleOnly => womenOnly,
        MatchGender.mixed => mixed,
      };

  @override String drillLevelLabel(DrillLevel level) => switch (level) {
        DrillLevel.beginner => beginner,
        DrillLevel.intermediate => intermediate,
        DrillLevel.advanced => advanced,
      };

  @override String targetSkillLabel(TargetSkill skill) => switch (skill) {
        TargetSkill.dribbling => dribbling,
        TargetSkill.shooting => shooting,
        TargetSkill.passing => passing,
        TargetSkill.speed => speed,
        TargetSkill.heading => heading,
        TargetSkill.stamina => stamina,
      };

  @override String announcementTypeLabel(AnnouncementType type) => switch (type) {
        AnnouncementType.trial => 'Essai',
        AnnouncementType.news => 'Actualités',
        AnnouncementType.tournament => 'Tournoi',
        AnnouncementType.officialTrial => 'Essai officiel',
      };

  @override String nYearsOld(int n) => '$n ans';
  @override String nDrillsAndCerts(int drills, int certs) => '$drills exercices · $certs certifs';
  @override String avgDrillScore(String score) => 'Moy. exercice : $score';

  @override String credibilityN(int n) => 'Crédibilité $n/100';
  @override String noStadiumsInCity(String city) => 'Pas encore de stades à $city.\nEssayez une autre ville.';
  @override String playersMax(int n) => '$n joueurs max';
  @override String target(String skill) => 'Cible : $skill';
  @override String nLessons(int n) => '$n leçons';
  @override String nMatches(int n) => '$n matchs';
  @override String nBadges(int n) => '$n badges';
  @override String nPitches(int n) => '$n terrains';
  @override String earnedDate(String date) => 'Obtenu le $date';
  @override String questionN(int n) => 'Question $n';
  @override String lessonN(int n) => 'Leçon $n';
  @override String rank(int n) => '#$n';
  @override String nPlayersMatched(int n) => '$n joueur(s) trouvé(s)';
  @override String nPlayersConfirmed(int cur, int max) => '$cur/$max joueurs confirmés';
  @override String agesRange(int min, int max) => '$min–$max ans';
  @override String organizerName(String name) => 'Organisateur : $name';
  @override String pricePerHr(String price) => '$price MAD/h';
  @override String quizScore(int pct, int correct, int total) => '$pct% ($correct/$total correct)';
  @override String nQuizQuestions(int n) => '$n questions de quiz';
  @override String nMembers(int n) => '$n membres';
  @override String squadCaptain(String name) => 'Capitaine : $name';
  @override String discoveryInCity(String city) => 'Découvrir $city';
  @override String nReferrals(int n) => '$n parrainage(s)';
  @override String referralShareMessage(String code) => 'Rejoins-moi sur KickPro ! Utilise mon code : $code';
}
