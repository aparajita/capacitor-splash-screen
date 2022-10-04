module.exports = {
  bumpFiles: [
    { filename: 'package.json', type: 'json' },
    { filename: 'src/info.json', type: 'json' }
  ],
  types: [
    { type: 'feat', section: 'Features' },
    { type: 'fix', section: 'Bug Fixes' },
    { type: 'chore', section: 'Maintenance' },
    { type: 'docs', section: 'Docs' },
    { type: 'style', section: 'Style' },
    { type: 'refactor', section: 'Refactoring' },
    { type: 'perf', section: 'Performance' },
    { type: 'test', hidden: true }
  ]
}
