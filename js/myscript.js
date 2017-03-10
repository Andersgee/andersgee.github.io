function formatAsUKDate(date) {
  var day = padWithZero(date.getDate(), 2);
  var month = padWithZero(date.getMonth()+1, 2);
  var year = date.getFullYear();
  return  day + '/' + month + '-' + year;
}

function padWithZero(str, minLength) {
  str = String(str);
  while (str.length < minLength) {
    str = '0' + str;
  }
  return str;
}
