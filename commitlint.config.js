//
//  commitlint.config.js
//  
//
//  Created by IntSur on 2026/1/8.
//

module.exports = {
  extends: ['gitmoji'],     // 来自 commitlint-config-gitmoji
  rules: {
    // 可按需覆盖，示例：限制标题长度
    'header-max-length': [2, 'always', 100],
  },
};
