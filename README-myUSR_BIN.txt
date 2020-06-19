#=vim source $VIM/itn-dc.vim
# version 2020.061902

[Targets]
c:\usr\bin     Binaries
c:\usr\vim     RunTime
c:\opt\*       Applications
c:\MinGW       GCCompilers
c:\usr\Install PackageRepo
                                             
[Resources]
https://www.vim.org
https://ftp.nluug.nl/pub/vim/  
https://winscp.net/download.php
https://gnuwin32.sourceforge.net                     

[Packages]
# cd c:\usr\Install\Portable; sha1sum * |clip
c4a5c58b63892d4f2a7af0a060c5f93fc2ca157a Lingea-2002-lnx.tar.gz
5c696b8e8f53742601406d1939a4bac3353f4047 Lingea-2002-win.7z
333326fead19670d9ecbd14ac9da6ffb7d65815b WinSCP-5.17.6-Portable.zip
17daebb82e476adfd578f6934c28f4d2c209b7d8 putty-0.73-unix-src.tar.gz
f1d19f7cee98b06a50b105cd23d8bca2d20599f2 putty-0.73-win-src.zip
2619b42586af2eb830b157068c55ac9f077df481 putty-0.73-win32.zip
d82b35ab395496fca39722ea9f588ca5495bca53 putty-0.73-win64.zip
de679dc1ade3caafbb27bc88071f1e00a677cdc2 vim73_46gvim2020-1.zip
cde31a99db352464be75078dbae9176a5b0722f3 vim73_46rt2020-1.zip
ec47a4b47aeb36a96c3e936640a6e58d35c1b813 vim73_46src2020-1.zip
3eb357fec3bff261a4a9c22704e030ae5363dc59 vim73_46w32_2020-1.zip

[Extraction]
Lingea-2002-win.7z\*             -R>> c:\opt\lingea
putty.zip\*.exe                  7x>> c:\usr\bin
putty.zip\*.chm                  1x>> c:\usr\bin
vim73_46w32.zip\vim.exe          1x>> c:\usr\bin
vim73_46w32.zip\xxd.exe          1x>> c:\usr\bin
gvim73_46w32.zip\gvim.exe        1x>> c:\usr\bin
vim73_46rt.zip\*                 -R>> c:\usr\vim
WinSCP-*-Portable.zip\winscp.exe 1x>> c:\usr\vim
coreutils-bin.zip\pwd.exe        1x>> c:\usr\bin
coreutils-dep.zip\*.dll          2x>> c:\usr\bin

[Post-Check]
40b8cd2cd738f3c59f917883980a65facca29e94 PAGEANT.EXE
14458e6bd4f511636d6226cd932dd5374bd9cd14 PAGEANT32.EXE
40b8cd2cd738f3c59f917883980a65facca29e94 PAGEANT64.EXE
47ee1b6f495db98143f821f9f8dd49448fe607c8 PLINK.EXE
06aaa9556963e9dc9e774540a786f893ece0fb0c PLINK32.EXE
47ee1b6f495db98143f821f9f8dd49448fe607c8 PLINK64.EXE
ee1b5f3a7f9563a9e7575edda467794584555f97 PSCP.EXE
73c6b63edc6e763fe70782afbb2b9be47baf82e4 PSCP32.EXE
ee1b5f3a7f9563a9e7575edda467794584555f97 PSCP64.EXE
b1947e46b493c9048f5cc76f992e16a9f43d5a3a PSFTP.EXE
cb0b39534d99057b02b090c3650fb1de43d19a02 PSFTP32.EXE
b1947e46b493c9048f5cc76f992e16a9f43d5a3a PSFTP64.EXE
0346fb3740921df43bc05db7dd15b65ac345cf98 PUTTY.CHM
d932604ab8e9debe475415851fd26929a0c0dcd1 PUTTY.EXE
0346fb3740921df43bc05db7dd15b65ac345cf98 PUTTY32.CHM
73016558c8353509b15cd757063816369e9abfa7 PUTTY32.EXE
0346fb3740921df43bc05db7dd15b65ac345cf98 PUTTY64.CHM
d932604ab8e9debe475415851fd26929a0c0dcd1 PUTTY64.EXE
a77eadf3d5e3e13ad5e6e4f54670cf57a8ec9315 PUTTYGEN.EXE
57539d9e94c2abcaab0eee2b5a199167b7053b88 PUTTYGEN32.EXE
a77eadf3d5e3e13ad5e6e4f54670cf57a8ec9315 PUTTYGEN64.EXE
cca0a173f570b539d971fcae9aee64cc974ed110 README-myUSR_BIN.txt
089d6c7873fb6b6ad6df003586082528badeedfe WinSCP.exe
19f1b1a7e7f83f4d441f6ef8e7994e4b0cf8410d WinSCP.ini
14e816f071669f4ddfb8928ab75698c269336d9a ben.cmd
f3ded5c6a92fae62466377d04a73880ee2eb6a68 cip.py
396b6d1bc933c0a57494811f74d954cd8a2b7763 cls2.pl
72ba644c2e549487178c8d2b4584bdae3a99da27 com10.cmd
21bf1ccd5b52af55b51d635cf7b3497b47041451 conemu.cmd
9dfe12d66d23253e656846031eb8c973a69e2778 cpan.cmd
7cc7d9dd235efa5eb3301ba4e8e86c8af450e41c cpass.pl
bd3d8feda5b4e4669be5ecf04285dec175fae39a craw.pl
5844aea9c1aa2c685e424f2bbefacc11c3d5450b crep.pl
cc39099cd83e3b0e581210f6a7adb847a5e403df crep.py
3719f9cd0a219ef8b12200d5defdb05d3c6c11c1 dbmmanage.pl
deed49b4471ffdefe6f8bbc66173f6c06c726d00 desktop.ini
4e16066ac7c22b9e5e7605bbb82092a595f43d62 dia.cmd
d98a6826f4b0ab9399562618aee59f58a8a8f510 display.cmd
b6f694bc87018294f8155166451e89704b127253 docs.cmd
c7426852020cb96188f52668b370b39cf0c2ab3a enter.pl
981331d587362d065f3ec08f04e7d3fffd811566 eri.cmd
3eb16b5523d5ad17e5eaa1299f984f6aecf9fb73 ff.pl
1211961672510025c2694e76e3897613c43075c2 ffox.cmd
d17917678738912431ca97725353c0d5eb39d73a fping.pl
e50a12df073049c48d8a52a709663cccb7cf4fa4 git.cmd
4d93aeea6e98b1239879e82cf8c8e4563ffca479 gitt.cmd
9e0fea0011f76c6e6bdd763f2961de6f4734d732 gs.cmd
ee80fc2c2f2c1ea1de924765c6d4b84cd5e64fa6 gsw.cmd
3645d0251605a39f52d209c927c895b5ea4c9f36 gunzip.cmd
2e2f50e6ac674e10f48bc018a5be576990128f13 gvim.exe
485226263eb8c86e9f9dca83949a733782e9fab1 gvimext.dll
3d3de299609c30a65e046e0fb58008563fefc68d ipf.cmd
fe87ede8555b42923232aac3e4016ece01f43b1f ipin.pl
b8217598c96e441bcd52c8b28ce92082f12e6e17 itn-lwports.pl
7cc840e666e4cedf1c6f8ae976a36a4a5cb8aa70 kody.pl
ef86242b9b9115f38e00c672b86a69d676fc91b6 kun.cmd
a95d0e85516a11fc30c684015a080d2eabec4bad lab.pl
a824bd18f21b339371a06dd71c4acfe5e6b8f15c lab_junos.cmd
45ddc10f386a0a957766c0dd46734927131a6a7a larson.cmd
2d9ff158ffa0161aac3aa2197c361bc56369a308 libiconv2.dll
da234dd17ce248c70159cfa4e469ef9767a978d0 libintl3.dll
4484e88a46663b6ecf006f518612850134eb5e9a log.cmd
535d7a97406209ccec4568fca2763bb9db1cd54c npp.cmd
bd81670e6c77ccd02d75754aa3a36f3ce844bae5 oskguest.cmd
5a40cc265f1e05b8ea3b05f76b12d2c6d69a0094 pass.cmd
b03dde28a933167598ee091d3156e624c1cf02a3 pdftk.cmd
56f6dc964dc02badd3572399a875e7fa82ee61c2 perl.cmd
d98a6826f4b0ab9399562618aee59f58a8a8f510 photo.cmd
679da77fcc74dbf1a4742ffa92056035d91b8aa4 pip.cmd
1a2254fb444b82ff7759d4e0c28b8820467bd838 pip.conf
679da77fcc74dbf1a4742ffa92056035d91b8aa4 pip2.cmd
341e71171a5f8a5d969ff4470a1c15681a6046ea pip2x.cmd
9897ef9a8e6e723b2362d08c5eaee968cd1a1f8f pip3.cmd
df262f4735b1d9e94293848960b6ce836422df13 pip3x.cmd
9605f901da43d3ad8caad24f6bbd7f4a22bf4eb0 pipx.cmd
dc67e356f5e91b6319d99c8a0abfad346550937b pm.pl
7f453a4ab434a765d30edf7a3edb9e37f829db15 pohoda.cmd
a30d69afeebeca9b090addf1baa4c58992b312cf ppm.cmd
5a42ae322b4b957113c5b3f6d54cec3f1936b81d pspad.cmd
85f5334257c48e72498636003e92c0c0e0f14cfa putty-backup.cmd
e31c235a643691d7d53fe058743f8b2f9f85b841 pwa.pl
2cb5ad26990661f144ea6da4d5866b809e917328 pwd.exe
7a3b753d6f7ddcc5c46b92c4ab345daec21d2ade px.cmd
44330de810dd5f168b0068f876ff4b74c60d40bb pym2.py
4446754d704c2dfd5dfacc781c6bd2aca5c87f04 pym3.py
f4af487719f24339aac081393028e798087ee544 pytest.py
f5f302524799454f1e6131785e4ee8905cdc3bce python.cmd
f5f302524799454f1e6131785e4ee8905cdc3bce python2.cmd
bad4bffdfd0eb3069db17f5cbd7b460bfb8d03aa python3.cmd
61a376a8fd3eb5fa94fc14c95f7bc04f3be27c9d sap.cmd
a749a1ff4d6622fa6ff298696df6992db359b9c0 scr.cmd
bf0460732c362412ab4ce4f89c81b9df5949a05b setpwd.cmd
8dad930e5bf4728c4f1317c0bb0f4231c98d54e2 sk.pl
94132e26e9ed0324fad90d5f1ab49e8a05736361 sqlff.cmd
390e6cb323da8e5f6d79f4659f82f3ccb9f98097 syslogd.cmd
d56efe1ece5affcc8d9e68c712c15264f238c0ed szlh.pl
170e8e6181ca6a13f3830d640d415f27e394ede5 template.py
56a8bac1b7a51828c2f12adc42c8cd46c4da1dff template_cs1.cmd
9b24e79161cd8f0a56ee197e9fb7291bc0aabc15 tftpd.cmd
485c65dd964c487201caa88b8d674b8170ed7d62 tickets.pl
506db8a40b1c29a754acc1fed1db80e5249a4c5b todo.cmd
2107fce6d8298724feaccede41e64f0eaa77fcef tool.pl
d755f994d2a4caabbee0d0f9ba69d7e591b774d9 trznica.cmd
f09415b6ddc8b4cf93504683167a0e8c258a2654 tshark.cmd
e885352f86a63cd49cfb4f1225ce1b5a7a369dfa txt2pdf.py
e67d338e7c922cc7882759a0e00152633d5a3625 udp-hello.py
33578603af3f72952b23493bd7bc5878bffe824c vb-gui.cmd
00de3b89550caa18297d46edb30efcd0b7447b24 vb.cmd
19e4577b593aa9911b965906b78d0b67edbdcf56 vi-cred.cmd
a907efef7161aa580c8e969d76cb15d143fc3ac5 vi.exe
a907efef7161aa580c8e969d76cb15d143fc3ac5 vim.exe
1e654b38a3b7bdc06965d5c148dac243cb96f0d6 vimrun.exe
46283994fc3b4cb88f2ec7e0074cde8d4b69934c vnc.cmd
a53333ab2424508c1524137e8538ce420ab1d007 vpn.cmd
44d91fb7ebd1447a2cb9928f8cefe7b728920cd5 vpnclient.cmd
e5af23dc107231dd666412eb4754f5462141f895 vscode.cmd
7f453a4ab434a765d30edf7a3edb9e37f829db15 wc30.cmd
55eb3ba91c0a5c46b308a3b8447b40aea05dd772 webapp.cmd
c26cb562db798448b55249de906ff71af57b7a84 wifi-acc.cmd
bf6bd8092855119e603262fae0602edc150b1cd1 wireshark.cmd
21a9a525fc11b090e86e1e5e13a4dfb0828713f8 wlc.cmd
e73d37a2484e07b28031350699bf1316d6837b3d wrap.pl
53f36e19456fe32dd7ee2bca2e9a4fd8aa5fac14 xxd.exe

# --- end ---
