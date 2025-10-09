Map<String, dynamic> getUserQueryPayload(String userId) {
  return {
    "model": "res.users",
    "method": "search_read",
    "args": [
      [
        ["id", "=", int.parse(userId)],
      ],
    ],
    "kwargs": {
      "fields": ["id", "name", "login", "email", "phone", "country_of_birth"],
    },
  };
}
