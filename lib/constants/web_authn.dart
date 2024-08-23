const String makeCredentialJson = '''
{
    "authenticatorExtensions": "",
    "clientDataHash": "LTCT/hWLtJenIgi0oUhkJz7dE8ng+pej+i6YI1QQu60=",
    "credTypesAndPubKeyAlgs": [
        ["public-key", -7]
    ],
    "excludeCredentials": [{
        "type": "public-key",
        "id": "lVGyXHwz6vdYignKyctbkIkJto/ADbYbHhE7+ss/87o="
    }],
    "requireResidentKey": true,
    "requireUserPresence": true,
    "requireUserVerification": false,
    "rp": {
        "name": "sultan",
        "id": "sultan"
    },
    "user": {
        "name": "testuser",
        "displayName": "Test User",
        "id": "/QIAAAAAAAAAAA=="
    }
}''';


