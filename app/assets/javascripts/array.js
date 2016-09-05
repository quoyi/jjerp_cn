/**
 * 扩展 JS Array 方法 indexOf
 * @param  {[type]} val [description]
 * @return {[type]}     [description]
 */
Array.prototype.indexOf = function(val) {
  for (var i = 0; i < this.length; i++) {
    if (this[i] == val) return i;
  }
  return -1;
};
/**
 * 扩展 JS Array 方法 remove
 * @param  {[type]} val [description]
 * @return {[type]}     [description]
 */
Array.prototype.remove = function(val) {
  var index = this.indexOf(val);
  if (index > -1) {
    this.splice(index, 1);
  }
};