/// Calculates the checksum for a request.
int calculateChecksum(List<int> data) {
  var checksum = 0;

  for (final value in data) {
    checksum += value;
    checksum = checksum % 0x100;
  }

  return checksum;
}

/// Evaluates the checksum of a response.
bool evaluateChecksum(List<int> data) {
  if (data.length > 1) {
    final expected = calculateChecksum(data.sublist(0, data.length - 1));
    return data.last == expected;
  }

  return false;
}
