set -o errexit -o nounset

rev=$(git rev-parse --short HEAD)

cd book

git init
git config user.name "Giang Nguyen"
git config user.email "nguyengiangdev@gmail.com"

git remote add upstream "https://$GH_TOKEN@github.com/rust-vietnam/blog.rust-lang.vn.git"
git fetch upstream 
git reset upstream/gh-pages

touch .

git add -A .
git commit -m "rebuild pages at ${rev}"
git push -q upstream HEAD:gh-pages > /dev/null 2>&1