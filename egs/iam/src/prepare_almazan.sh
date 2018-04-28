#!/bin/bash
set -e;

# Directory where the script is placed.
SDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)";
# CD to the main directory for the experiment.
cd "${SDIR}/..";

mkdir -p data/almazan/lang/{char,word};
# Prepare word-level transcriptions.
[ -s data/almazan/lang/word/all.txt ] ||
awk '{
  img = $NF;
  wrd = tolower($(NF - 1));
  split(img, arr, "-");
  printf("%-27s %s\n", arr[1]"/"arr[1]"-"arr[2]"/"img, wrd);
}' data/almazan/queries.gtp > data/almazan/lang/word/all.txt;

# Prepare char-level transcriptions.
[ -s data/almazan/lang/char/all.txt ] ||
awk '{
  printf("%-27s", $1);
  for (i=1;i<=length($2);++i) {
    printf(" %s", substr($2, i, 1));
  }
  printf("\n");
}' data/almazan/lang/word/all.txt > data/almazan/lang/char/all.txt;

# Prepare symbols list for PHOCNet training
[ -s data/almazan/lang/syms_phoc.txt ] ||
cut -d\  -f2- data/almazan/lang/char/all.txt | tr \  \\n | awk 'NF > 0' |
sort -uV | awk '{
  printf("%s %d\n", $1, NR - 1);
}' > data/almazan/lang/syms_phoc.txt;

# Prepare symbols list for CTCNet training
[ -s data/almazan/lang/syms_ctc.txt ] ||
awk 'BEGIN{
  printf("<ctc> %d\n", NR);
}{
  printf("%-5s %d\n", $1, NR);
}' data/almazan/lang/syms_phoc.txt > data/almazan/lang/syms_ctc.txt;

# Prepare stop words list.
[ -s data/almazan/lang/word/stopwords.txt ] ||
cat data/almazan/swIAM.txt | tr \, \\n > data/almazan/lang/word/stopwords.txt;

# Prepare character-level stop words list.
[ -s data/almazan/lang/char/stopwords.txt ] ||
awk '{
  printf("%s", substr($1, 1, 1));
  for (i=2; i<=length($1); ++i) printf(" %s", substr($1, i, 1));
  printf("\n");
}' data/almazan/lang/word/stopwords.txt > data/almazan/lang/char/stopwords.txt;
