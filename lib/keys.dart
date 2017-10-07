/// Spotitem version
const String version = '0.3.0';

/// Storage key of user data
const String keyUser = 'KEY_USER';

/// Storage key of refresh_token
const String keyOauthToken = 'KEY_AUTH_TOKEN';

/// Storage key of provider
const String keyProvider = 'KEY_AUTH_PROVIDER';

/// Storage key of last email used
const String keyLastEmail = 'KEY_LAST_EMAIL';

/// Storage key of settings
const String keySettings = 'KEY_SETTINGS';

/// Api secret
const String clientSecret = 'et+nWhUB>.Dg[c4z';

/// Api URL
const String apiUrl = 'http://217.182.65.67:3417/api';

/// Api img URL
const String apiImgUrl = 'http://217.182.65.67:3417/img/';

/// Google map static Api key
const String staticApiKey = 'AIzaSyAJh3ASTwUBo06fQai_PZJa-R9czeRC2D0';

/// List of login providers
final List<String> providers = <String>['google', 'local'];

/// Get headers for Api
Map<String, String> getHeaders([String key]) => <String, String>{
      'Authorization': key,
      'spotkey': 'Basic $clientSecret',
      'accept-version': version,
      'Accept': 'application/json'
    };
