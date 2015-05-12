Everything should be done as user dpovey_gmail_com.
When someone has done an upload, to rebuild the site, do:

./make_all.sh

When I wanted to remove a build (build 9) that turned out to be
incomplete, I did this: (OK, actually I didn't do this exactly, I
added the option --all to make_all.sh, but I think this was
unnecessary).

sudo rm -rf ../downloads/submitted/9
rm -r ../downloads/build_index/9
rm -r ../downloads/build/9
./make_all.sh

