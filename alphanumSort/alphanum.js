// alphanum sort 20141210
//
// How to use:
//  arr = ["a8", "b5", "a20"];
//  arr.sort();
//  console.log(arr); // ["a20", "a8", "b5"]
//  arr.sort(alphanumSort);
//  console.log(arr); // ["a8", "a20", "b5"]

function isNum(c)
{
  var n0 = "0".charCodeAt(0);
  var n9 = "9".charCodeAt(0);
  return n0 <= c && c <= n9;
}
function lenNum(str, start)
{
  var i = start;
  for(;i<str.length;i++)
  {
    if(!isNum(str.charCodeAt(i)))return i-start;
  }
  return i-start;
}
function alphanumSort(a, b)
{
  var i=0, j=0;
  var c1, c2;
  var n0 = "0".charCodeAt(0);
  var n9 = "9".charCodeAt(0);
  while(i<a.length && j<b.length)
  {
    c1 = a.charCodeAt(i);
    c2 = b.charCodeAt(j);
    if(isNum(c1) && isNum(c2))
    {
      var len1 = lenNum(a, i);
      var len2 = lenNum(b, j);
      if(len1 > len2)
      {
        while(len1!=len2)
        {
          if(a.charCodeAt(i)!=n0)return 1;
          i++;
          len1--;
        }
      }
      else if(len1 < len2)
      {
        while(len1!=len2)
        {
          if(b.charCodeAt(j)!=n0)return -1;
          j++;
          len2--;
        }
      }
      c1 = a.charCodeAt(i);
      c2 = b.charCodeAt(j);
    }
    if(c1 != c2)return c1-c2;
    i++;
    j++;
  }
  return 0;
}
