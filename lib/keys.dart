/// Spotitem version
const String version = '0.4.0';

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

/// Api base host
//const String baseHost = '217.182.65.67:3417';
//const String baseHost = '192.168.1.119:1337';
const String baseHost = '192.168.0.21:1337';

/// Api URL
const String apiUrl = 'http://$baseHost/api';

/// Api img URL
const String apiImgUrl = '$apiUrl/img/';

/// Google map static Api key
const String staticApiKey = 'AIzaSyAJh3ASTwUBo06fQai_PZJa-R9czeRC2D0';

/// Google place Api key
const String placeApiKey = 'AIzaSyASWp3kPIbc3SR9962dhQLWMtJQWvQqRcs';

/// Google geo Api key
const String geoApiKey = 'AIzaSyCj88TURPJSYF28VhIaslc8JQXTJV19Dvw';

/// List of login providers
final List<String> providers = <String>['google', 'local'];

/// Get headers for Api
Map<String, String> getHeaders([String key]) => <String, String>{
      'Authorization': key,
      'Spotkey': 'Basic $clientSecret-$version',
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };
