var path = require('path');
var gulp = require('gulp');
var eslint = require('gulp-eslint');
var nodemon = require('gulp-nodemon');
var rename = require('gulp-rename');
var del = require('del');
var nodemonObj;

gulp.task('eslint', () => {
  gulp
    .src(['**/*.js'])
    .pipe(eslint({
      envs: ['node', 'es6'],
      extends: 'eslint:recommended',
      rules: {
        "eqeqeq": 2
      }
    }))
    .pipe(eslint.format())
    .pipe(eslint.failAfterError());
});

gulp.task('clean', callback => {
    return del.sync(['public/**/*'], callback);
});

gulp.task('compile-client', () => {
  gulp
    .src('config/index.html')
    .pipe(gulp.dest('public'));

  gulp
    .src('plugins/*/client/**/*')
    .pipe(rename(p =>{
        p.dirname = p.dirname.split(path.sep).filter((f,i)=>i!=1).join(path.sep);
    }))
    .pipe(gulp.dest('public'));
});

gulp.task('default', ['clean', 'compile-client']);

gulp.task('watch', () => {
    gulp.watch(['config/index.html', 'plugins/*/client/**'], ['compile-client']);
    gulp.watch(['config/index.js', 'plugins/*/server/**'], () => {nodemonObj.restart();});
});

gulp.task('serve', ['watch'], () => {
  nodemonObj = nodemon({
    script: 'config/index.js',
    ignore: '**/**'
  });
});
