/*

  VectorMath.dart
  
  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>
  
  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

#import ('dart:builtin');
#import ('dart:core');
#import ('dart:io');

void ListSwap(List<int> seq, int i, int j) {
  int temp = seq[i];
  seq[i] = seq[j];
  seq[j] = temp;
}

void ListReverse(List<int> seq, int first, int last) {
  while (first != last && first != --last) {
    ListSwap(seq, first++, last);
  }  
}

bool ListNextPermutation(List<int> seq, int first, int last) {
  if (first == last) {
    return false;
  }
  if (first+1 == last) {
    return false;
  }
  int i = last-1;
  for (;;) {
    int ii = i--;
    if (seq[i] < seq[ii]) {
      int j = last;
      while (!(seq[i] < seq[--j])) {
        continue;
      }
      ListSwap(seq, i, j);
      ListReverse(seq, ii, last);
      return true;
    }
    if (i == first) {
      ListReverse(seq, first, last);
      return false;
    }
  }
}

List<String> PrintablePermutation(List<int> seq, List<String> components) {
  List<String> r = new List<String>(seq.length);
  for (int i = 0; i < seq.length; i++) {
    r[i] = components[seq[i]];
  }
  return r;
}

class VectorGenerator {
  List<String> vectorComponents;
  int get vectorDimension() {
    return vectorComponents != null ? vectorComponents.length : 0;
  } 
  String vectorType;
  int vectorLen;
  List<String> allTypes;
  List<int> allTypesLength;
  List<List<String>> componentAliases;
  String generatedName;
  int _indent;
  RandomAccessFile out;
  
  VectorGenerator() {
    _indent = 0;
  }

  void iPush() {
    _indent++;
  }
  void iPop() {
    _indent--;
    assert(_indent >= 0);
  }
  void iPrint(String s) {
    String indent = "";
    for (int i = 0; i < _indent; i++) {
      indent += '  ';
    }
    out.writeString('$indent$s\n');
    print('$indent$s');
  }
  
  void writeLicense() {
    iPrint('''/*

  VectorMath.dart
  
  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>
  
  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/''');
  }
  
  void generatePrologue() {
    iPrint('class $generatedName {');
    iPush();
    vectorComponents.forEach((comp) {
      iPrint('$vectorType $comp;');
    }); 
  }
  
  void generateAliases() {
    for (List<String> ca in componentAliases) {
      for (int i = 0; i < ca.length; i++) {
        iPrint('$vectorType get ${ca[i]}() => ${vectorComponents[i]};');
        iPrint('set ${ca[i]}($vectorType arg) => ${vectorComponents[i]} = arg;');
      }
    }
  }
  
  String joinStrings(List<String> elements, [String pre = '', String post = '', String joiner = ', ']) {
    bool first = true;
    String r = '';
    for (String e in elements) {
      r += first ? '${pre}${e}${post}' : '${joiner}${pre}${e}${post}';
      first = false;
    }
    return r;
  }
  
  void generateDefaultConstructor() {
    iPrint('$generatedName([${joinStrings(vectorComponents, 'Dynamic ', '_')}]) {');
    iPush();
    iPrint('${joinStrings(vectorComponents, joiner: ' = ')} = 0.0;');
    
    if (generatedName == 'vec3') {
      iPrint('if (${vectorComponents[0]}_ is vec2 && ${vectorComponents[1]}_ is num) {');
      iPush();
      iPrint('this.xy = ${vectorComponents[0]}_.xy;');
      iPrint('this.z = ${vectorComponents[1]}_;');
      iPop();
      iPrint('}');
      
      iPrint('if (${vectorComponents[0]}_ is num && ${vectorComponents[1]}_ is vec2) {');
      iPush();
      iPrint('this.x = ${vectorComponents[0]}_.x;');
      iPrint('this.yz = ${vectorComponents[1]}_.xy;');
      iPop();
      iPrint('}');
      
      iPrint('if (${vectorComponents[0]}_ is vec2 && ${vectorComponents[1]}_ == null) {');
      iPush();
      iPrint('this.xy = ${vectorComponents[0]}_.xy;');
      iPrint('this.z = 0;');
      iPop();
      iPrint('}');
    } else if (generatedName == 'vec4') {
      iPrint('if (${vectorComponents[0]}_ is vec3 && ${vectorComponents[1]}_ is num) {');
      iPush();
      iPrint('this.xyz = ${vectorComponents[0]}_.xyz;');
      iPrint('this.w = ${vectorComponents[1]}_;');
      iPop();
      iPrint('}');
      
      iPrint('if (${vectorComponents[0]}_ is num && ${vectorComponents[1]}_ is vec3) {');
      iPush();
      iPrint('this.x = ${vectorComponents[0]}_;');
      iPrint('this.yzw = ${vectorComponents[1]}_.xyz;');
      iPop();
      iPrint('}');
      
      iPrint('if (${vectorComponents[0]}_ is vec3 && ${vectorComponents[1]}_ == null) {');
      iPush();
      iPrint('this.xyz = ${vectorComponents[0]}_.xyz;');
      iPrint('this.z = 0;');
      iPop();
      iPrint('}');
      
      iPrint('if (${vectorComponents[0]}_ is vec2 && ${vectorComponents[1]}_ is vec2) {');
      iPush();
      iPrint('this.xy = ${vectorComponents[0]}_.xy;');
      iPrint('this.zw = ${vectorComponents[1]}_.xy;');
      iPop();
      iPrint('}');
    }
    iPrint('if (${vectorComponents[0]}_ is $generatedName) {');
    iPush();
    iPrint('${joinStrings(vectorComponents, joiner: '')} = ${vectorComponents[0]}_.${joinStrings(vectorComponents, joiner: '')};');
    iPrint('return;');
    iPop();
    iPrint('}');
    
    iPrint('if (${joinStrings(vectorComponents, '', '_ is num', ' && ')}) {');
    iPush();
    for (String e in vectorComponents) {
      iPrint('$e = ${e}_;');
    }
    iPrint('return;');
    iPop();
    iPrint('}');
    
    iPrint('if (${vectorComponents[0]}_ is num) {');
    iPush();
    iPrint('${joinStrings(vectorComponents, joiner: ' = ')} = ${vectorComponents[0]}_;');
    iPrint('return;');
    iPop();
    iPrint('}');
    
    iPop();
    iPrint('}');
  }
  
  void generateToString() {
    String code = 'String toString() => \'';
    bool first = true;
    vectorComponents.forEach((comp) {
      code += first ? '\$$comp' : ',\$$comp';
      first = false;
    });
    code += '\';';
    iPrint(code);
  }
  
  void generateSplat() {
    String constructor = '$generatedName.splat($vectorType a) : ';
    bool first = true;
    vectorComponents.forEach((comp) {
      constructor += first ? '$comp = a' : ', $comp = a';
      first = false;
    });
    constructor += ';';
    iPrint(constructor);
    iPrint('void splat($vectorType a) {');
    iPush();
    vectorComponents.forEach((comp) {
      iPrint('$comp = a;');
    });
    iPop();
    iPrint('}');
  }
  
  void generateOperator(String op) {
    String code = '$generatedName operator$op($generatedName other) => new $generatedName(';
    bool first = true;
    vectorComponents.forEach((comp) {
      code += first ? '$comp $op other.$comp' :', $comp $op other.$comp'; 
      first = false;
    });
    code += ');';
    iPrint(code);
  }
  
  void generateScaleOperator(String op) {
    iPrint('$generatedName operator$op(Dynamic other) {');
    iPush();
    
    iPrint('if (other is num) {');
    {
      iPush();
      String code = 'return new $generatedName(';
      bool first = true;
      vectorComponents.forEach((comp) {
        code += first ? '$comp $op other' :', $comp $op other'; 
        first = false;
      });
      code += ');';
      iPrint(code);
      iPop();
      iPrint('}');
    }
    iPrint('if (other is $generatedName) {');
    {
      iPush();
      bool first = true;
      String code = 'return new $generatedName(';
      vectorComponents.forEach((comp) {
        code += first ? '$comp $op other.$comp' :', $comp $op other.$comp'; 
        first = false;
      });
      code += ');';
      iPrint(code);
      iPop();
      iPrint('}');
    }
    
    iPop();
    iPrint('}');
  }
  
  void generateNegateOperator() {
    String op = '-';
    String code = '$generatedName operator negate() => new $generatedName(';
    bool first = true;
    vectorComponents.forEach((comp) {
      code += first ? '$op$comp' :', $op$comp'; 
      first = false;
    });
    code += ');';
    iPrint(code);
  }
  
  void generateIndexOperator() {
    iPrint('$vectorType operator[](int i) {');
    iPush();
    iPrint('assert(i >= 0 && i < $vectorDimension);');
    iPrint('switch (i) {');
    iPush();
    int i = 0;
    vectorComponents.forEach((comp) {
      iPrint('case $i: return $comp; break;');
      i++;
    });
    iPop();
    iPrint('};');
    iPrint('return 0.0;');
    iPop();
    iPrint('}');
  }
  
  void generateAssignIndexOperator() {
    iPrint('$vectorType operator[]=(int i, $vectorType v) {');
    iPush();
    iPrint('assert(i >= 0 && i < $vectorDimension);');
    iPrint('switch (i) {');
    iPush();
    int i = 0;
    vectorComponents.forEach((comp) {
      iPrint('case $i: $comp = v; return $comp; break;');
      i++;
    });
    iPop();
    iPrint('};');
    iPrint('return 0.0;');
    iPop();
    iPrint('}');
  }
  
  /*
  void generateSetter(List<int> seq, String type) {
    List<String> comps = PrintablePermutation(seq, vectorComponents);
    var propertyName = "";
    comps.forEach((e) => propertyName += e);
    iPrint('set $propertyName($type arg) \{');
    iPush();
    int i = 0;
    comps.forEach((e) {
      iPrint('$e = arg.${vectorComponents[i]};');
      i++;
    });
    iPop();
    iPrint('\}');
  }
  
  void generateSetters() {
    List<int> dimensions = new List<int>(vectorDimension);
    for (int i = 0; i < vectorDimension; i++) {
      dimensions[i] = i;
    }
    var components = dimensions.getRange(0, vectorDimension);
    var permutation = new List.from(components);
    generateSetter(permutation);
    var N = permutation.length;
    while (ListNextPermutation(permutation, 0, vectorDimension)) {
      generateSetter(permutation);
    }
  }
  
  
  void generateSetters() {
    List<int> dimensions = new List<int>(vectorDimension);
    for (int i = 0; i < vectorDimension; i++) {
      dimensions[i] = i;
    }
    for (int d = 1; d < vectorDimension; d++) {
      var components = dimensions.getRange(0, d+1);
      var permutation = new List.from(components);
      generateSetter(permutation, allTypes[d-1]);
      var N = permutation.length;
      while (ListNextPermutation(permutation, 0, d+1)) {
        generateSetter(permutation, allTypes[d-1]);
      }
    }
  }
  */
  
  void generateSettersForType(String type, int len, String pre, int i, int j) {
    if (i == len) {
      iPrint('set $pre($type arg) {');
      iPush();
      int z = 0;
      for (String c in pre.splitChars()) {
        iPrint('$c = arg.${vectorComponents[z]};');
        z++;
      }
      iPop();
      iPrint('}');
      /*
      String code = 'set $pre($type arg) => new $type(';
      bool first = true;
      pre.splitChars().forEach((c) {
        code += first ? '$c' : ', $c';  
        first = false;
      });
      code += ');';
      iPrint(code);
      return;
      */
      return;
    }
    if (j == len) {
      return;
    }
    for (int a = 0; a < vectorDimension; a++) {
      if (pre.charCodes().indexOf(vectorComponents[a].charCodeAt(0)) != -1) {
        continue;
      }
      String property_name = pre + vectorComponents[a];
      generateSettersForType(type, len, property_name, i+1, 0);
    }
  }
  
  void generateSetters() {
    for (int i = 0; i < allTypes.length; i++) {
      var type = allTypes[i];
      var len = allTypesLength[i];
      generateSettersForType(type, len, '', 0, 0);
      if (type == generatedName) {
        break;
      }
    }
  }
  
  
  void generateGettersForType(String type, int len, String pre, int i, int j) {
    if (i == len) {
      String code = '$type get $pre() => new $type(';
      bool first = true;
      pre.splitChars().forEach((c) {
        code += first ? '$c' : ', $c';  
        first = false;
      });
      code += ');';
      iPrint(code);
      return;
    }
    if (j == len) {
      return;
    }
    for (int a = 0; a < vectorDimension; a++) {
      String property_name = pre + vectorComponents[a];
      generateGettersForType(type, len, property_name, i+1, 0);
    }
  }
  
  void generateGetters() {
    for (int i = 0; i < allTypes.length; i++) {
      var type = allTypes[i];
      var len = allTypesLength[i];
      generateGettersForType(type, len, '', 0, 0);
    }
  }
  
  void generateLength() {
    iPrint('num get length() {');
    iPush();
    iPrint('num sum = 0.0;');
    vectorComponents.forEach((comp) {
      iPrint('sum += ($comp * $comp);');
    });
    iPrint('return Math.sqrt(sum);');
    iPop();
    iPrint('}');
  }
  
  void generateLength2() {
    iPrint('num get length2() {');
    iPush();
    iPrint('num sum = 0.0;');
    vectorComponents.forEach((comp) {
      iPrint('sum += ($comp * $comp);');
    });
    iPrint('return sum;');
    iPop();
    iPrint('}');
  }
  
  void generateNormalize() {
    iPrint('void normalize() {');
    iPush();
    iPrint('num l = length;');
    vectorComponents.forEach((comp) {
      iPrint('$comp /= l;');
    });
    iPop();
    iPrint('}');
  }
  
  void generateDot() {
    iPrint('num dot($generatedName other) {');
    iPush();
    iPrint('num sum = 0.0;');
    vectorComponents.forEach((comp) {
      iPrint('sum += ($comp * other.$comp);');
    });
    iPrint('return sum;');
    iPop();
    iPrint('}');
  }
  
  void generateCross() {
    iPrint('$generatedName cross($generatedName other) {');
    iPush();
    iPrint('return new $generatedName(y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x);');
    iPop();
    iPrint('}');
  }
  
  void generateEpilogue() {
    iPop();
    iPrint('}');
  }
  
  void generate() {
    writeLicense();
    generatePrologue();
    generateAliases();
    generateSplat();
    generateToString();
    generateNegateOperator();
    generateOperator('-');
    generateOperator('+');
    generateScaleOperator('/');
    generateScaleOperator('*');
    generateIndexOperator();
    generateAssignIndexOperator();
    generateSetters();
    generateGetters();
    {
      var backup = vectorComponents;
      for (List<String> ca in componentAliases) {
        vectorComponents = ca;
        generateSetters();
        generateGetters();
      }
      vectorComponents = backup;
    }
    generateLength();
    generateLength2();
    generateNormalize();
    generateDot();
    if (generatedName == 'vec3') {
      generateCross();
    }
    generateDefaultConstructor();
    generateEpilogue();
  }
}

void main() {
  String basePath = 'lib/VectorMath/gen';
  var f;
  
  f = new File('${basePath}/vec2_gen.dart');
  f.onError = (error) {
    print('$error');
  };
  f.open(FileMode.WRITE, (opened) {
    print('opened');
    VectorGenerator vg = new VectorGenerator();
    vg.allTypes = ['vec2', 'vec3', 'vec4'];
    vg.allTypesLength = [2,3,4];
    vg.vectorType = 'num';
    vg.vectorComponents = ['x','y'];
    vg.componentAliases = [ ['r','g'], ['s','t']];
    vg.generatedName = 'vec2';
    vg.vectorLen = 2;
    vg.out = opened;
    vg.generate();
    opened.close(() {});
  });
  f = new File('${basePath}/vec3_gen.dart');
  f.onError = (error) {
    print('$error');
  };
  f.open(FileMode.WRITE, (opened) {
    print('opened');
    VectorGenerator vg = new VectorGenerator();
    vg.allTypes = ['vec2', 'vec3', 'vec4'];
    vg.allTypesLength = [2,3,4];
    vg.vectorType = 'num';
    vg.vectorComponents = ['x','y', 'z'];
    vg.componentAliases = [ ['r','g', 'b'], ['s','t', 'p']];
    vg.generatedName = 'vec3';
    vg.vectorLen = 3;
    vg.out = opened;
    vg.generate();
    opened.close(() {});
  });
  f = new File('${basePath}/vec4_gen.dart');
  f.onError = (error) {
    print('$error');
  };
  f.open(FileMode.WRITE, (opened) {
    print('opened');
    VectorGenerator vg = new VectorGenerator();
    vg.allTypes = ['vec2', 'vec3', 'vec4'];
    vg.allTypesLength = [2,3,4];
    vg.vectorType = 'num';
    vg.vectorComponents = ['x','y', 'z', 'w'];
    vg.componentAliases = [ ['r','g', 'b', 'a'], ['s','t', 'p', 'q']];
    vg.generatedName = 'vec4';
    vg.vectorLen = 4;
    vg.out = opened;
    vg.generate();
    opened.close(() {});
  });
}