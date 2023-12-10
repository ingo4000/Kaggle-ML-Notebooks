{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "c9171ba9",
   "metadata": {
    "papermill": {
     "duration": 0.021005,
     "end_time": "2023-12-10T23:26:54.368011",
     "exception": false,
     "start_time": "2023-12-10T23:26:54.347006",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# BDA 2023 Profiling Personality\n",
    "## Group 06\n",
    "\n",
    "In this notebook, we harness methods introduced in ISLR Chapters 1-3 to predict vloggers' personality axes based on the YouTube personality dataset. We report each step of the modeling process, from data import to model evaluation. To remain concise, we omit some guiding information supplied in the quick-start notebook while maintaining its general structure.\n",
    "\n",
    "To summarise our approach to this task, one main focus was to gather many features from the provided dataset. We computed features based on our own rationale, ultimately relying on model fit statistics to infer which features were most valuable."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ae4ea077",
   "metadata": {
    "papermill": {
     "duration": 0.016805,
     "end_time": "2023-12-10T23:26:54.403069",
     "exception": false,
     "start_time": "2023-12-10T23:26:54.386264",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# Environment and Input Directory Setup\n",
    "In this part, we setup the working environment prior to importing and structuring the data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "d7a44864",
   "metadata": {
    "_cell_guid": "39fc8038-1e29-4bb3-8486-160aa629127b",
    "_execution_state": "idle",
    "_uuid": "047afe52-49c0-4445-bc38-8ce6b6825e9d",
    "collapsed": false,
    "execution": {
     "iopub.execute_input": "2023-12-10T23:26:54.444350Z",
     "iopub.status.busy": "2023-12-10T23:26:54.440187Z",
     "iopub.status.idle": "2023-12-10T23:26:57.552843Z",
     "shell.execute_reply": "2023-12-10T23:26:57.550481Z"
    },
    "jupyter": {
     "outputs_hidden": false
    },
    "papermill": {
     "duration": 3.13635,
     "end_time": "2023-12-10T23:26:57.556103",
     "exception": false,
     "start_time": "2023-12-10T23:26:54.419753",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "── \u001b[1mAttaching core tidyverse packages\u001b[22m ──────────────────────── tidyverse 2.0.0 ──\n",
      "\u001b[32m✔\u001b[39m \u001b[34mdplyr    \u001b[39m 1.1.2     \u001b[32m✔\u001b[39m \u001b[34mreadr    \u001b[39m 2.1.4\n",
      "\u001b[32m✔\u001b[39m \u001b[34mforcats  \u001b[39m 1.0.0     \u001b[32m✔\u001b[39m \u001b[34mstringr  \u001b[39m 1.5.0\n",
      "\u001b[32m✔\u001b[39m \u001b[34mggplot2  \u001b[39m 3.4.2     \u001b[32m✔\u001b[39m \u001b[34mtibble   \u001b[39m 3.2.1\n",
      "\u001b[32m✔\u001b[39m \u001b[34mlubridate\u001b[39m 1.9.2     \u001b[32m✔\u001b[39m \u001b[34mtidyr    \u001b[39m 1.3.0\n",
      "\u001b[32m✔\u001b[39m \u001b[34mpurrr    \u001b[39m 1.0.1     \n",
      "── \u001b[1mConflicts\u001b[22m ────────────────────────────────────────── tidyverse_conflicts() ──\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mfilter()\u001b[39m masks \u001b[34mstats\u001b[39m::filter()\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mlag()\u001b[39m    masks \u001b[34mstats\u001b[39m::lag()\n",
      "\u001b[31m✖\u001b[39m \u001b[34mdplyr\u001b[39m::\u001b[32mselect()\u001b[39m masks \u001b[34mMASS\u001b[39m::select()\n",
      "\u001b[36mℹ\u001b[39m Use the conflicted package (\u001b[3m\u001b[34m<http://conflicted.r-lib.org/>\u001b[39m\u001b[23m) to force all conflicts to become errors\n"
     ]
    }
   ],
   "source": [
    "# load necessary packages\n",
    "library(MASS)\n",
    "library(tidyverse) \n",
    "library(tidytext)\n",
    "\n",
    "# setup directory\n",
    "master_dir <- file.path(list.files(\"../input\", full.names = TRUE), \"youtube-personality\")\n",
    "directory_content <- list.files(master_dir, full.names = TRUE)\n",
    "\n",
    "# define path to the transcripts directory\n",
    "path_to_transcripts <- directory_content[2]\n",
    "\n",
    "# define path to .csv filenames\n",
    "AudioVisual_file <- directory_content[3]\n",
    "Gender_file <- directory_content[4]\n",
    "Personality_file <- directory_content[5]"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f736542e",
   "metadata": {
    "_cell_guid": "1e2591f6-6257-49b6-b8ca-5211d63b2c15",
    "_uuid": "5564aff0-1b9a-4ad0-8deb-c59822efb02f",
    "papermill": {
     "duration": 0.01748,
     "end_time": "2023-12-10T23:26:57.590857",
     "exception": false,
     "start_time": "2023-12-10T23:26:57.573377",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# 1. Data Import\n",
    "\n",
    "We import transcripts, personality scores, gender, and audivisual data. We conducted checks on the structure of different data throughout the import but removed them from the submitted version."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "id": "e8520e26",
   "metadata": {
    "_cell_guid": "83284cd6-8b82-4e44-b327-a7bb30035ea1",
    "_uuid": "9bb0363f-c1e8-4e78-95e8-240628cd1c56",
    "collapsed": false,
    "execution": {
     "iopub.execute_input": "2023-12-10T23:26:57.678622Z",
     "iopub.status.busy": "2023-12-10T23:26:57.628075Z",
     "iopub.status.idle": "2023-12-10T23:26:59.715646Z",
     "shell.execute_reply": "2023-12-10T23:26:59.713154Z"
    },
    "jupyter": {
     "outputs_hidden": false
    },
    "papermill": {
     "duration": 2.110819,
     "end_time": "2023-12-10T23:26:59.719216",
     "exception": false,
     "start_time": "2023-12-10T23:26:57.608397",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\u001b[1mRows: \u001b[22m\u001b[34m324\u001b[39m \u001b[1mColumns: \u001b[22m\u001b[34m6\u001b[39m\n",
      "\u001b[36m──\u001b[39m \u001b[1mColumn specification\u001b[22m \u001b[36m────────────────────────────────────────────────────────\u001b[39m\n",
      "\u001b[1mDelimiter:\u001b[22m \" \"\n",
      "\u001b[31mchr\u001b[39m (1): vlogId\n",
      "\u001b[32mdbl\u001b[39m (5): Extr, Agr, Cons, Emot, Open\n",
      "\n",
      "\u001b[36mℹ\u001b[39m Use `spec()` to retrieve the full column specification for this data.\n",
      "\u001b[36mℹ\u001b[39m Specify the column types or set `show_col_types = FALSE` to quiet this message.\n"
     ]
    }
   ],
   "source": [
    "# Import transcripts ---------------------------\n",
    "transcript_files <- list.files(path_to_transcripts, full.names = TRUE)\n",
    "\n",
    "# Extract vlogger ID\n",
    "vlogId <- basename(transcript_files)\n",
    "vlogId <- str_replace(vlogId, pattern = \".txt$\", replacement = \"\")\n",
    "\n",
    "# Create transcripts dataframe\n",
    "transcripts_df <- tibble(\n",
    "\n",
    "  # vlogId connects each transcripts to a vlogger\n",
    "  vlogId = vlogId,\n",
    "\n",
    "  # Read the transcript text from all file and store as a string\n",
    "  TEXT = suppressWarnings(map_chr(transcript_files, ~ paste(readLines(.x), collapse = \"\\\\n\"))),\n",
    "\n",
    "  # `filename` keeps track of the specific video transcript\n",
    "  filename = transcript_files\n",
    ")\n",
    "\n",
    "# Import personality scores ---------------------------\n",
    "pers_df <- read_delim(Personality_file, delim = \" \")\n",
    "\n",
    "# Import gender ---------------------------\n",
    "gender_df <- read.delim(Gender_file, head = FALSE, sep = \" \", skip = 2)\n",
    "\n",
    "# Add column names\n",
    "names(gender_df) <- c(\"vlogId\", \"gender\")\n",
    "\n",
    "# Merge gender and pers dataframes ---------------------------\n",
    "vlogger_df <- left_join(gender_df, pers_df, by = \"vlogId\")\n",
    "\n",
    "# Import audiovisual data ---------------------------\n",
    "audiovisual_df <- read.delim(AudioVisual_file, sep = \"\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e208bce9",
   "metadata": {
    "papermill": {
     "duration": 0.01718,
     "end_time": "2023-12-10T23:26:59.753665",
     "exception": false,
     "start_time": "2023-12-10T23:26:59.736485",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# 2. Feature extraction from transcript texts\n",
    "We separate this section into the following subchapters:\n",
    "\n",
    "* **Tokenization**\n",
    "    - Word-based tokenization\n",
    "    - Sentence-based tokenization\n",
    "    - Stopwords removal\n",
    "* **Feature Group 1: Sentence Structure**\n",
    "    - Number of sentences\n",
    "    - Average (and variance of) number of words per sentence\n",
    "    - Percentage of questions    \n",
    "* **Feature Group 2: Specific Words**\n",
    "    - Pronouns\n",
    "    - Swear words\n",
    "    - Filler words\n",
    "* **Feature Group 3: Sentiment Analysis**\n",
    "    - NRC\n",
    "* **Feature Group 4: Audiovisual Data**\n",
    "    - Voice pitch \n",
    "    - Energy\n",
    "    - Speaking time\n",
    "* **Merging of the Datasets**\n",
    "    "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "7366b6c0",
   "metadata": {
    "papermill": {
     "duration": 0.01735,
     "end_time": "2023-12-10T23:26:59.788311",
     "exception": false,
     "start_time": "2023-12-10T23:26:59.770961",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.1 Tokenization\n",
    "For the extractions of the different features we need different tokenization processes:\n",
    "* Sentence tokenization\n",
    "* Word tokenization\n",
    "* Stopword removal"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fb96f32e",
   "metadata": {
    "papermill": {
     "duration": 0.019458,
     "end_time": "2023-12-10T23:26:59.824886",
     "exception": false,
     "start_time": "2023-12-10T23:26:59.805428",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.1.2 Sentence Tokenization\n",
    "For the purpose of extracting features from structural properties of the transcripts, we unnest the transcripts using \"sentences\" as tokens. That way, we can for example compute the number of sentences or the use of questionmarks."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "id": "2164f14c",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:26:59.872650Z",
     "iopub.status.busy": "2023-12-10T23:26:59.870539Z",
     "iopub.status.idle": "2023-12-10T23:26:59.988930Z",
     "shell.execute_reply": "2023-12-10T23:26:59.986440Z"
    },
    "papermill": {
     "duration": 0.144785,
     "end_time": "2023-12-10T23:26:59.991928",
     "exception": false,
     "start_time": "2023-12-10T23:26:59.847143",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "token_sentences <- transcripts_df %>%\n",
    "  dplyr::select(-filename) %>%\n",
    "  unnest_tokens(sentence, TEXT, token = \"sentences\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "92d1afbf",
   "metadata": {
    "papermill": {
     "duration": 0.017109,
     "end_time": "2023-12-10T23:27:00.026574",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.009465",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "Additionally, we unnest the sentences into a word based tokenization in order to calculate word per sentence statistics."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "1f4ccb45",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:00.065420Z",
     "iopub.status.busy": "2023-12-10T23:27:00.063249Z",
     "iopub.status.idle": "2023-12-10T23:27:00.283850Z",
     "shell.execute_reply": "2023-12-10T23:27:00.281369Z"
    },
    "papermill": {
     "duration": 0.243503,
     "end_time": "2023-12-10T23:27:00.287135",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.043632",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "token_words_sentence <- token_sentences %>%\n",
    "  group_by(vlogId) %>%\n",
    "  mutate(sentence_nr = row_number()) %>%\n",
    "  ungroup() %>%\n",
    "  unnest_tokens(words, sentence, token = \"words\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "101e656e",
   "metadata": {
    "papermill": {
     "duration": 0.017124,
     "end_time": "2023-12-10T23:27:00.321667",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.304543",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.1.2 Word Tokenization\n",
    "Here, we unnest the transcripts using a word based tokenization in order to be extract sentiment feature and features regarding the use of specific words."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "7ccce78f",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:00.360764Z",
     "iopub.status.busy": "2023-12-10T23:27:00.358687Z",
     "iopub.status.idle": "2023-12-10T23:27:00.556455Z",
     "shell.execute_reply": "2023-12-10T23:27:00.554233Z"
    },
    "papermill": {
     "duration": 0.220561,
     "end_time": "2023-12-10T23:27:00.559339",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.338778",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "token_words <- transcripts_df %>%\n",
    "  dplyr::select(-filename) %>%\n",
    "  unnest_tokens(token, TEXT, token = \"words\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2d6717a6",
   "metadata": {
    "papermill": {
     "duration": 0.017864,
     "end_time": "2023-12-10T23:27:00.594933",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.577069",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.1.3 Remove Stopwords\n",
    "For some feature extractions we need a dataset with stop words removed."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "a972364e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:00.634779Z",
     "iopub.status.busy": "2023-12-10T23:27:00.632891Z",
     "iopub.status.idle": "2023-12-10T23:27:00.720823Z",
     "shell.execute_reply": "2023-12-10T23:27:00.718075Z"
    },
    "papermill": {
     "duration": 0.11138,
     "end_time": "2023-12-10T23:27:00.723844",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.612464",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "stopwords <- get_stopwords()\n",
    "token_no_stop_words <- token_words %>%\n",
    "  anti_join(stopwords, by = c(token = \"word\"))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "40d1c9f5",
   "metadata": {
    "papermill": {
     "duration": 0.017408,
     "end_time": "2023-12-10T23:27:00.758374",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.740966",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.2 Feature Group 1: Sentence Structure\n",
    "We compute the following variables:\n",
    "\n",
    "| variable name     | description                                                | justification                                                                      |\n",
    "|-------------------|------------------------------------------------------------|------------------------------------------------------------------------------------|\n",
    "| `n_sentences`     | number of sentences                                        | can reflect communication style                                                    |\n",
    "| `mean_words_sent` | average number of words per sentence                       | can reflect thought patterns, detail-orientation                                   |\n",
    "| `var_words_sent`  | variance of number of words per sentence                   | can reflect predictability, consistency, and highlight traits of conscientiousness |\n",
    "| `perc_quest`      | percentage of sentences ending with a \"?\" (vs \".\" and \"!\") | can reflect openness to experience, extraversion                                   |\n",
    "\n",
    "**Rationale**\n",
    "\n",
    "* The number of sentences is essentially a measure of how long the transcripts are. We expect the length of a transcript to have an effect on the personality judgment by other. For example, vloggers who use many sentences might be perceived as more open and more extravert.\n",
    "\n",
    "* The average number of words per sentence is affecting how long the sentences are and thereby might represent a valuable predictor for personality traits such as extraversion because vloggers how use long sentences might be perceived as individuals who enjoy communicating their opinions and sharing ideas.\n",
    "\n",
    "* The variance of number of words per sentence represents a measure of how the sentence length (and possibly even the structure) varies within the transcript. Here, we expect vloggers who show a high variance to be perceived as highly agreeable because changing the sentences length and structure might make the narrative and storytelling more appealing to follow.\n",
    "\n",
    "* Finally asking questions might be related to insecurity (introversion) or to curiousness (openness to experience). Here we calculate the percentage of questions versus sentences ending with a point or an exclamation mark because we don't want the measure to be confounded with the length of the transcript."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "3f02e2ea",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:00.797987Z",
     "iopub.status.busy": "2023-12-10T23:27:00.796003Z",
     "iopub.status.idle": "2023-12-10T23:27:01.227550Z",
     "shell.execute_reply": "2023-12-10T23:27:01.225235Z"
    },
    "papermill": {
     "duration": 0.454992,
     "end_time": "2023-12-10T23:27:01.230641",
     "exception": false,
     "start_time": "2023-12-10T23:27:00.775649",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\u001b[1m\u001b[22m`summarise()` has grouped output by 'vlogId'. You can override using the\n",
      "`.groups` argument.\n",
      "\u001b[1m\u001b[22m`summarise()` has grouped output by 'vlogId'. You can override using the\n",
      "`.groups` argument.\n"
     ]
    }
   ],
   "source": [
    "# mean_words_sent, var_words_sent ---------------------------\n",
    "stats_words_sentence <- token_words_sentence %>%\n",
    "  group_by(vlogId, sentence_nr) %>%\n",
    "  summarise(n_words = n()) %>%\n",
    "  group_by(vlogId) %>%\n",
    "  summarise(\n",
    "    mean_words_sent = mean(n_words),\n",
    "    var_words_sent = var(n_words),\n",
    "  ) %>%\n",
    "  # for VLOG22 there is only 1 sentence, so we need to set the var to 0, instead of NA\n",
    "  mutate(var_words_sent = ifelse(is.na(var_words_sent), 0, var_words_sent))\n",
    "\n",
    "\n",
    "# use of \"?\" vs. \".\" and \"!\" ---------------------------\n",
    "stats_punctuation <- token_sentences %>%\n",
    "  mutate(ending = str_sub(sentence, -1)) %>%\n",
    "  group_by(vlogId, ending) %>%\n",
    "  summarize(n_ending = n()) %>%\n",
    "  ungroup() %>%\n",
    "  pivot_wider(names_from = ending, values_from = n_ending, values_fill = 0) %>%\n",
    "  # there are a few endings that might be caused by transcription errors. We'll focus on ?, ., !\n",
    "  dplyr::select(1:4) %>%\n",
    "  # since the number of sentences varies, we need to transform the count into a percentage\n",
    "  mutate(\n",
    "    sum = sum(c(`.`, `?`, `!`), na.rm = TRUE),\n",
    "    perc_quest = `?` / sum,\n",
    "    perc_excla = `!` / sum,\n",
    "    perc_point = `.` / sum\n",
    "  )\n",
    "\n",
    "# join the variables together ---------------------------\n",
    "stats_sent_str <- stats_words_sentence %>%\n",
    "  left_join(\n",
    "    stats_punctuation %>%\n",
    "      dplyr::select(vlogId, perc_quest),\n",
    "    by = \"vlogId\"\n",
    "  )"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "feaec989",
   "metadata": {
    "papermill": {
     "duration": 0.01771,
     "end_time": "2023-12-10T23:27:01.266034",
     "exception": false,
     "start_time": "2023-12-10T23:27:01.248324",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.3 Feature Group 2: Specific Words\n",
    "We'll take a look at the following specific words and the frequency of their occurence\n",
    "\n",
    "* Pronouns\n",
    "* Swear Words\n",
    "* Filler Words\n",
    "\n",
    "We compute the following variables:\n",
    "\n",
    "| variable name       | description                                                | justification                                                        |\n",
    "|---------------------|------------------------------------------------------------|----------------------------------------------------------------------|\n",
    "| `first_vs_second`   | rate of first case vs. second case pronouns                | empathy, agreeableness (outward) or introspection, self-orientation  |\n",
    "| `self_vs_we`        | rate of singular first case vs. plural first case pronouns | social orientation cues that may highlight Big 5 personality traits  |\n",
    "| `third_vs_other`    | rate of third case pronoun vs. all other pronouns          | empathy, self-focus                                                  |\n",
    "| `perc_swear`        | rate of swear words vs. other words (stop words)           | may highlight authenticity or use of sensationalism                  |\n",
    "| `perc_filler_words` | rate of filler words (uh, uhm, uh) vs. all other words     | may relate to confidence in speech, traits of anxiety or nervousness |\n",
    "\n",
    "The rationale for extracting these features is shortly described in the respective section."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "0df950b5",
   "metadata": {
    "papermill": {
     "duration": 0.017401,
     "end_time": "2023-12-10T23:27:01.300954",
     "exception": false,
     "start_time": "2023-12-10T23:27:01.283553",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.3.1 Pronouns\n",
    "The three features concerning pronouns are computed as relative frequencies in order to avoid confundation with other structural variables.\n",
    "\n",
    "**Rationale**\n",
    "\n",
    "* `first_vs_second`: The use of self-referential words might be connected to the zero acquaintance personality jugdements on multiple personality traits. For example, research showed a correlation between the use of the word \"I\" and neuroticism (Scully & Terry, 2011).\n",
    "\n",
    "* `self_vs_we`: The rate of singular first case pronouns versus plural first case pronouns might indicate that vloggers are perceived as more selfish and the audience might feel less included. Therefore, we expect this feature to be a good predictor for the perceived agreeableness.\n",
    "\n",
    "* `third_vs_other`: We expect this rate to be a good predictor for low neuroticism as vloggers might be perceived as less self-obsessed."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "83f79e07",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:01.341509Z",
     "iopub.status.busy": "2023-12-10T23:27:01.339457Z",
     "iopub.status.idle": "2023-12-10T23:27:01.860804Z",
     "shell.execute_reply": "2023-12-10T23:27:01.858551Z"
    },
    "papermill": {
     "duration": 0.545149,
     "end_time": "2023-12-10T23:27:01.864033",
     "exception": false,
     "start_time": "2023-12-10T23:27:01.318884",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# define pronoun word lists ---------------------------\n",
    "words_self <- c(\"i\", \"me\", \"myself\", \"mine\", \"my\", \"i'm\", \"i'd\", \"i've\")\n",
    "words_we <- c(\"we\", \"ours\", \"ourself\", \"ourselves\", \"our\", \"we're\", \"we've\", \"we'd\", \"us\")\n",
    "words_you <- c(\"you\", \"your\", \"yours\", \"yourself\", \"you're\", \"you've\", \"you'd\")\n",
    "words_third <- c(\n",
    "  \"him\", \"his\", \"her\", \"herself\", \"himself\", \"he\", \"she\", \"he'd\", \"he's\", \"she'd\",\n",
    "  \"she's\", \"them\", \"their\", \"themthelves\", \"they\", \"they're\", \"they've\", \"they'd\"\n",
    ")\n",
    "\n",
    "# compute stats ---------------------------\n",
    "stats_pronouns <- token_words %>%\n",
    "  # identify the respective words\n",
    "  mutate(\n",
    "    self = token %in% words_self,\n",
    "    we = token %in% words_we,\n",
    "    you = token %in% words_you,\n",
    "    third = token %in% words_third\n",
    "  ) %>%\n",
    "  # compute the number of words for each word list\n",
    "  group_by(vlogId) %>%\n",
    "  summarise(\n",
    "    n_selfwords = sum(self),\n",
    "    n_wewords = sum(we),\n",
    "    n_firstcase = n_selfwords + n_wewords,\n",
    "    n_youwords = sum(you),\n",
    "    n_thirdwords = sum(third),\n",
    "  ) %>%\n",
    "  ungroup() %>%\n",
    "  # calculate percentages\n",
    "  mutate(\n",
    "    first_vs_second = n_firstcase / (n_firstcase + n_youwords),\n",
    "    self_vs_we = n_selfwords / (n_selfwords + n_wewords),\n",
    "    third_vs_other = n_thirdwords / (n_firstcase + n_youwords)\n",
    "  )"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "80456100",
   "metadata": {
    "papermill": {
     "duration": 0.017647,
     "end_time": "2023-12-10T23:27:01.899727",
     "exception": false,
     "start_time": "2023-12-10T23:27:01.882080",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.3.2 Swear words\n",
    "We use an online list for swear words in order to obtain a measure of the use of swear words by the bloggers. Here, we compute the percentage of swear words to the number of all non stop words used because we want to gain a measure of the relative frequency of swear words in the transcripts.\n",
    "\n",
    "**Rationale:**\n",
    "Vloggers who use swear words more frequently are expected to be perceived as less agreeable because the audience might not perceive those vloggers as polite or friendly. \n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "23a3719d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:01.939651Z",
     "iopub.status.busy": "2023-12-10T23:27:01.937701Z",
     "iopub.status.idle": "2023-12-10T23:27:02.681000Z",
     "shell.execute_reply": "2023-12-10T23:27:02.678567Z"
    },
    "papermill": {
     "duration": 0.767452,
     "end_time": "2023-12-10T23:27:02.684753",
     "exception": false,
     "start_time": "2023-12-10T23:27:01.917301",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "swear_words_url <- \"http://www.bannedwordlist.com/lists/swearWords.txt\"\n",
    "download.file(swear_words_url, destfile = \"swear_words.txt\")\n",
    "swear_words <- pull(read.table(\"swear_words.txt\",\n",
    "  stringsAsFactor = FALSE,\n",
    "  sep = \",\"\n",
    "), V1)\n",
    "\n",
    "#' We'll take the dataset in which we removed the stop words because we want to compare the number\n",
    "#' of swear words to the number of non swear words excluding stop words.\n",
    "stats_swear <- token_no_stop_words %>%\n",
    "  # Add TRUE if token is a swear word\n",
    "  mutate(swearcheck = token %in% swear_words) %>%\n",
    "  # Count swear words\n",
    "  group_by(vlogId) %>%\n",
    "  count(swearcheck) %>%\n",
    "  pivot_wider(names_from = swearcheck, values_from = n, values_fill = 0) %>%\n",
    "  # percentage of swear words vs. non swear words\n",
    "  mutate(perc_swear = `TRUE` / (`FALSE` + `TRUE`))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "7ef4e4ed",
   "metadata": {
    "papermill": {
     "duration": 0.017635,
     "end_time": "2023-12-10T23:27:02.720215",
     "exception": false,
     "start_time": "2023-12-10T23:27:02.702580",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.3.3 Filler words\n",
    "These filler words (here \"uh\", \"uhm\", \"um\") might be used to avoid silences. \n",
    "\n",
    "**Rationale:** We expect the use of filler words to indicate a difficulty finding words to say which may be related to a low perceived extraversion judgment, for example. Additionally, research suggests that specific filler words, discourse markers (e.g. You know, I mean), may be more common among conscienscious individuals (Laserna et al., 2014)."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "id": "bd5fab74",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:02.760841Z",
     "iopub.status.busy": "2023-12-10T23:27:02.758669Z",
     "iopub.status.idle": "2023-12-10T23:27:02.881342Z",
     "shell.execute_reply": "2023-12-10T23:27:02.878813Z"
    },
    "papermill": {
     "duration": 0.147091,
     "end_time": "2023-12-10T23:27:02.885172",
     "exception": false,
     "start_time": "2023-12-10T23:27:02.738081",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# define filler words ---------------------------\n",
    "filler_words <- c(\"uh\", \"uhm\", \"um\")\n",
    "\n",
    "stats_filler_words <- token_no_stop_words %>%\n",
    "  group_by(vlogId) %>%\n",
    "  count(token %in% filler_words) %>%\n",
    "  pivot_wider(\n",
    "    names_from = 2,\n",
    "    values_from = n,\n",
    "    values_fill = 0\n",
    "  ) %>%\n",
    "  ungroup() %>%\n",
    "  mutate(perc_filler_words = `TRUE` / (`FALSE` + `TRUE`))\n",
    "\n",
    "# join features ---------------------------\n",
    "stats_spec_words <- stats_pronouns %>%\n",
    "  dplyr::select(vlogId, first_vs_second, self_vs_we, third_vs_other) %>%\n",
    "  left_join(\n",
    "    stats_swear %>%\n",
    "    dplyr::select(vlogId, perc_swear),\n",
    "    by = \"vlogId\"\n",
    "  ) %>%\n",
    "  left_join(\n",
    "    stats_filler_words %>%\n",
    "    dplyr::select(vlogId, perc_filler_words),\n",
    "    by = \"vlogId\"\n",
    "  )"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "72916af4",
   "metadata": {
    "papermill": {
     "duration": 0.017801,
     "end_time": "2023-12-10T23:27:02.920775",
     "exception": false,
     "start_time": "2023-12-10T23:27:02.902974",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.4 Feature Group 3: Sentiment Features\n",
    "The NRC is a database that can be used to label words with 8 common emotions, which are either negative or positive. \n",
    "\n",
    "**Rationale:** The use of words labelled as each emotion might predict certain personality trait judgments. In earlier research sentiment analysis using NRC was shown to be an valuable personality predictor (Lin, Wang & Hao, 2023).\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 11,
   "id": "3f264fff",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:03.024107Z",
     "iopub.status.busy": "2023-12-10T23:27:03.021999Z",
     "iopub.status.idle": "2023-12-10T23:27:03.041867Z",
     "shell.execute_reply": "2023-12-10T23:27:03.039357Z"
    },
    "papermill": {
     "duration": 0.045959,
     "end_time": "2023-12-10T23:27:03.045507",
     "exception": false,
     "start_time": "2023-12-10T23:27:02.999548",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Helper function to retrieve different lexicons from the 'textdata' package\n",
    "get_lexicon = function(lexicon_name = names(textdata:::download_functions)) {\n",
    "    lexicon_name = match.arg(lexicon_name)\n",
    "    textdata:::download_functions[[lexicon_name]]('.')\n",
    "    rds_filename = paste0(lexicon_name,'.rds')\n",
    "    textdata:::process_functions[[lexicon_name]]('.',rds_filename)\n",
    "    readr::read_rds(rds_filename)\n",
    "}"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 12,
   "id": "22b74259",
   "metadata": {
    "_cell_guid": "f80d89e3-c233-4a5d-ba0c-7f1ca9fb1b04",
    "_uuid": "1540d512-f479-4475-aaa9-45c3acae5178",
    "collapsed": false,
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:03.085818Z",
     "iopub.status.busy": "2023-12-10T23:27:03.083749Z",
     "iopub.status.idle": "2023-12-10T23:27:05.631663Z",
     "shell.execute_reply": "2023-12-10T23:27:05.629403Z"
    },
    "jupyter": {
     "outputs_hidden": false
    },
    "papermill": {
     "duration": 2.572354,
     "end_time": "2023-12-10T23:27:05.635619",
     "exception": false,
     "start_time": "2023-12-10T23:27:03.063265",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 2</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>word</th><th scope=col>sentiment</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>secession</td><td>negative    </td></tr>\n",
       "\t<tr><td>gunpowder</td><td>fear        </td></tr>\n",
       "\t<tr><td>income   </td><td>anticipation</td></tr>\n",
       "\t<tr><td>surprise </td><td>surprise    </td></tr>\n",
       "\t<tr><td>gonorrhea</td><td>anger       </td></tr>\n",
       "\t<tr><td>blemish  </td><td>sadness     </td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 2\n",
       "\\begin{tabular}{ll}\n",
       " word & sentiment\\\\\n",
       " <chr> & <chr>\\\\\n",
       "\\hline\n",
       "\t secession & negative    \\\\\n",
       "\t gunpowder & fear        \\\\\n",
       "\t income    & anticipation\\\\\n",
       "\t surprise  & surprise    \\\\\n",
       "\t gonorrhea & anger       \\\\\n",
       "\t blemish   & sadness     \\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 2\n",
       "\n",
       "| word &lt;chr&gt; | sentiment &lt;chr&gt; |\n",
       "|---|---|\n",
       "| secession | negative     |\n",
       "| gunpowder | fear         |\n",
       "| income    | anticipation |\n",
       "| surprise  | surprise     |\n",
       "| gonorrhea | anger        |\n",
       "| blemish   | sadness      |\n",
       "\n"
      ],
      "text/plain": [
       "  word      sentiment   \n",
       "1 secession negative    \n",
       "2 gunpowder fear        \n",
       "3 income    anticipation\n",
       "4 surprise  surprise    \n",
       "5 gonorrhea anger       \n",
       "6 blemish   sadness     "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# use NRC ---------------------------\n",
    "nrc <- get_lexicon(\"nrc\")\n",
    "sample_n(nrc, 6)\n",
    "\n",
    "\n",
    "# label the tokenized transcripts ---------------------------\n",
    "token_nrc_label <- token_words %>%\n",
    "  left_join(nrc,\n",
    "    by = c(token = \"word\"),\n",
    "    relationship = \"many-to-many\"\n",
    "  )\n",
    "\n",
    "# computing sentiment counts ---------------------------\n",
    "transcript_sentiment_count <-\n",
    "  token_nrc_label %>%\n",
    "  count(`vlogId`, sentiment) %>%\n",
    "  pivot_wider(id_cols = \"vlogId\", names_from = sentiment, values_from = n, values_fill = 0) %>%\n",
    "  dplyr::select(-`NA`) %>%\n",
    "  # add \"nrc_\" prefix to variables\n",
    "  rename_at(\n",
    "    .vars = vars(-1),\n",
    "    .fun = ~ paste0(\"nrc_\", .)\n",
    "  )\n",
    "\n",
    "# computing percentage on all words (excluding no stop words), since transcripts differ in length\n",
    "transcript_sentiment_scores <-\n",
    "  transcript_sentiment_count %>%\n",
    "  # join total word count\n",
    "  left_join(\n",
    "    token_no_stop_words %>%\n",
    "      count(vlogId),\n",
    "    by = \"vlogId\"\n",
    "  ) %>%\n",
    "  # compute percentage\n",
    "  mutate_at(\n",
    "    .vars = vars(nrc_anger:nrc_trust),\n",
    "    .funs = list(~ . / n)\n",
    "  )"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f8365d23",
   "metadata": {
    "papermill": {
     "duration": 0.018042,
     "end_time": "2023-12-10T23:27:05.671847",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.653805",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.5 Feature Group 4: Audiovisual Data\n",
    "\n",
    "We compute the following audiovisual variables:\n",
    "\n",
    "| variable name   | description                                         | justification                                                                                                                                                       |\n",
    "|-----------------|-----------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|\n",
    "| `mean.pitch`    | average voice pitch used in video                   | pitch can reflect communication style                                                                                                                               |\n",
    "| `sd.pitch`      | variance of voice pitch                             | variability in pitch may convey the ability to display a range of emotions, possibly reflecting personality traits including extraversion or neuroticism            |\n",
    "| `mean.energy`   | vloggers' excitement and kinetic activity in videos | may reflect enthusiasm, engagement with audience, and highlight social cue to predict personality                                                                   |\n",
    "| `sd.energy`     | variance of excitement and kinetic activity         | change in energy can highlight adaptability, creativity that may translate to personality traits                                                                    |\n",
    "| `time.speaking` | time spent speaking                                 | speaking duration can reflect traits including extraversion, detail-orientation, and help predict related personalities                                             |\n",
    "| `speech_pace`   | pace used to speak                                  | speaking pace can give insight into the deliberateness of communication and help differentiate between enthusiasm, energy, and conscientiousness (Lee et al., 2021) |"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 13,
   "id": "12c82253",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:05.712655Z",
     "iopub.status.busy": "2023-12-10T23:27:05.710664Z",
     "iopub.status.idle": "2023-12-10T23:27:05.762703Z",
     "shell.execute_reply": "2023-12-10T23:27:05.760462Z"
    },
    "papermill": {
     "duration": 0.076693,
     "end_time": "2023-12-10T23:27:05.766481",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.689788",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "stats_audiovisual <- audiovisual_df %>%\n",
    "  dplyr::select(vlogId, mean.pitch, sd.pitch, mean.energy, sd.energy, time.speaking) %>%\n",
    "  left_join(\n",
    "    token_words %>%\n",
    "      count(vlogId),\n",
    "    by = \"vlogId\"\n",
    "  ) %>%\n",
    "  rename(n_words = n) %>%\n",
    "  mutate(speech_pace = n_words / time.speaking) %>%\n",
    "  dplyr::select(-n_words)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "168a19bb",
   "metadata": {
    "papermill": {
     "duration": 0.01797,
     "end_time": "2023-12-10T23:27:05.802685",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.784715",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.5 Merge datasets\n",
    "* Next, we first merge all the extracted features together.\n",
    "* Second, we merge the resulting data frame with the response data in order to be able to fit models and make predictions.\n",
    "* Third, we split the data frame into training and test data."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ce61e7c0",
   "metadata": {
    "papermill": {
     "duration": 0.017995,
     "end_time": "2023-12-10T23:27:05.838778",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.820783",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.5.1 Merge extracted features:\n",
    "\n",
    "Once we have computed features from the transcript texts and stored it in a data frame, we merge it with the `vlogger_df` dataframe:\n",
    "* vlogger_df\n",
    "  - ID\n",
    "  - gender\n",
    "  - personality scores (zero acquaintance judgment)\n",
    "* audiovisual features \n",
    "* transcript features\n",
    "  - sentence structure features\n",
    "  - specific word features\n",
    "  - sentiment features"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "id": "b4322acb",
   "metadata": {
    "_cell_guid": "f8532d3c-a6d0-430b-82bc-496bc93587e6",
    "_uuid": "471f379b-78cb-40bc-a81a-4e74969ec4d6",
    "collapsed": false,
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:05.879460Z",
     "iopub.status.busy": "2023-12-10T23:27:05.877562Z",
     "iopub.status.idle": "2023-12-10T23:27:05.968992Z",
     "shell.execute_reply": "2023-12-10T23:27:05.966694Z"
    },
    "jupyter": {
     "outputs_hidden": false
    },
    "papermill": {
     "duration": 0.114727,
     "end_time": "2023-12-10T23:27:05.971554",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.856827",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A data.frame: 6 × 26</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>vlogId</th><th scope=col>gender</th><th scope=col>mean.pitch</th><th scope=col>sd.pitch</th><th scope=col>mean.energy</th><th scope=col>sd.energy</th><th scope=col>time.speaking</th><th scope=col>speech_pace</th><th scope=col>mean_words_sent</th><th scope=col>var_words_sent</th><th scope=col>⋯</th><th scope=col>nrc_anger</th><th scope=col>nrc_anticipation</th><th scope=col>nrc_disgust</th><th scope=col>nrc_fear</th><th scope=col>nrc_joy</th><th scope=col>nrc_negative</th><th scope=col>nrc_positive</th><th scope=col>nrc_sadness</th><th scope=col>nrc_surprise</th><th scope=col>nrc_trust</th></tr>\n",
       "\t<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>1</th><td>VLOG3</td><td>Female</td><td>239.32</td><td>0.36474</td><td>0.0021029</td><td>1.28980</td><td>0.51374</td><td> 729.9412</td><td>18.750000</td><td>182.82895</td><td>⋯</td><td> 1</td><td>11</td><td> 2</td><td>2</td><td> 7</td><td> 2</td><td>10</td><td> 4</td><td> 6</td><td> 9</td></tr>\n",
       "\t<tr><th scope=row>2</th><td>VLOG5</td><td>Male  </td><td>173.50</td><td>0.47636</td><td>0.0031128</td><td>2.04870</td><td>0.70205</td><td> 562.6380</td><td>19.750000</td><td>253.88158</td><td>⋯</td><td> 1</td><td> 6</td><td> 1</td><td>2</td><td> 4</td><td> 1</td><td>10</td><td> 1</td><td> 4</td><td> 5</td></tr>\n",
       "\t<tr><th scope=row>3</th><td>VLOG6</td><td>Male  </td><td>201.28</td><td>0.27454</td><td>0.0321370</td><td>0.97954</td><td>0.75993</td><td> 818.4964</td><td>22.214286</td><td>236.17460</td><td>⋯</td><td> 5</td><td>11</td><td> 4</td><td>4</td><td>19</td><td>12</td><td>29</td><td> 3</td><td>11</td><td>24</td></tr>\n",
       "\t<tr><th scope=row>4</th><td>VLOG7</td><td>Male  </td><td>275.68</td><td>0.48758</td><td>0.1286000</td><td>1.23270</td><td>0.60069</td><td>1072.1004</td><td>16.947368</td><td>218.64580</td><td>⋯</td><td>12</td><td>22</td><td>11</td><td>7</td><td>12</td><td>15</td><td>21</td><td>11</td><td> 9</td><td>16</td></tr>\n",
       "\t<tr><th scope=row>5</th><td>VLOG8</td><td>Female</td><td>255.58</td><td>0.42310</td><td>0.0320580</td><td>1.62360</td><td>0.46439</td><td> 669.6957</td><td> 7.404762</td><td> 21.80778</td><td>⋯</td><td> 3</td><td>12</td><td> 2</td><td>6</td><td> 7</td><td> 5</td><td>12</td><td> 4</td><td> 3</td><td> 9</td></tr>\n",
       "\t<tr><th scope=row>6</th><td>VLOG9</td><td>Female</td><td>230.75</td><td>0.22081</td><td>0.0014254</td><td>1.53720</td><td>0.67458</td><td>1294.1386</td><td>14.311475</td><td>130.88470</td><td>⋯</td><td> 9</td><td>17</td><td> 8</td><td>8</td><td>15</td><td>18</td><td>30</td><td> 5</td><td>11</td><td>21</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A data.frame: 6 × 26\n",
       "\\begin{tabular}{r|lllllllllllllllllllll}\n",
       "  & vlogId & gender & mean.pitch & sd.pitch & mean.energy & sd.energy & time.speaking & speech\\_pace & mean\\_words\\_sent & var\\_words\\_sent & ⋯ & nrc\\_anger & nrc\\_anticipation & nrc\\_disgust & nrc\\_fear & nrc\\_joy & nrc\\_negative & nrc\\_positive & nrc\\_sadness & nrc\\_surprise & nrc\\_trust\\\\\n",
       "  & <chr> & <chr> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & ⋯ & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int>\\\\\n",
       "\\hline\n",
       "\t1 & VLOG3 & Female & 239.32 & 0.36474 & 0.0021029 & 1.28980 & 0.51374 &  729.9412 & 18.750000 & 182.82895 & ⋯ &  1 & 11 &  2 & 2 &  7 &  2 & 10 &  4 &  6 &  9\\\\\n",
       "\t2 & VLOG5 & Male   & 173.50 & 0.47636 & 0.0031128 & 2.04870 & 0.70205 &  562.6380 & 19.750000 & 253.88158 & ⋯ &  1 &  6 &  1 & 2 &  4 &  1 & 10 &  1 &  4 &  5\\\\\n",
       "\t3 & VLOG6 & Male   & 201.28 & 0.27454 & 0.0321370 & 0.97954 & 0.75993 &  818.4964 & 22.214286 & 236.17460 & ⋯ &  5 & 11 &  4 & 4 & 19 & 12 & 29 &  3 & 11 & 24\\\\\n",
       "\t4 & VLOG7 & Male   & 275.68 & 0.48758 & 0.1286000 & 1.23270 & 0.60069 & 1072.1004 & 16.947368 & 218.64580 & ⋯ & 12 & 22 & 11 & 7 & 12 & 15 & 21 & 11 &  9 & 16\\\\\n",
       "\t5 & VLOG8 & Female & 255.58 & 0.42310 & 0.0320580 & 1.62360 & 0.46439 &  669.6957 &  7.404762 &  21.80778 & ⋯ &  3 & 12 &  2 & 6 &  7 &  5 & 12 &  4 &  3 &  9\\\\\n",
       "\t6 & VLOG9 & Female & 230.75 & 0.22081 & 0.0014254 & 1.53720 & 0.67458 & 1294.1386 & 14.311475 & 130.88470 & ⋯ &  9 & 17 &  8 & 8 & 15 & 18 & 30 &  5 & 11 & 21\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A data.frame: 6 × 26\n",
       "\n",
       "| <!--/--> | vlogId &lt;chr&gt; | gender &lt;chr&gt; | mean.pitch &lt;dbl&gt; | sd.pitch &lt;dbl&gt; | mean.energy &lt;dbl&gt; | sd.energy &lt;dbl&gt; | time.speaking &lt;dbl&gt; | speech_pace &lt;dbl&gt; | mean_words_sent &lt;dbl&gt; | var_words_sent &lt;dbl&gt; | ⋯ ⋯ | nrc_anger &lt;int&gt; | nrc_anticipation &lt;int&gt; | nrc_disgust &lt;int&gt; | nrc_fear &lt;int&gt; | nrc_joy &lt;int&gt; | nrc_negative &lt;int&gt; | nrc_positive &lt;int&gt; | nrc_sadness &lt;int&gt; | nrc_surprise &lt;int&gt; | nrc_trust &lt;int&gt; |\n",
       "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n",
       "| 1 | VLOG3 | Female | 239.32 | 0.36474 | 0.0021029 | 1.28980 | 0.51374 |  729.9412 | 18.750000 | 182.82895 | ⋯ |  1 | 11 |  2 | 2 |  7 |  2 | 10 |  4 |  6 |  9 |\n",
       "| 2 | VLOG5 | Male   | 173.50 | 0.47636 | 0.0031128 | 2.04870 | 0.70205 |  562.6380 | 19.750000 | 253.88158 | ⋯ |  1 |  6 |  1 | 2 |  4 |  1 | 10 |  1 |  4 |  5 |\n",
       "| 3 | VLOG6 | Male   | 201.28 | 0.27454 | 0.0321370 | 0.97954 | 0.75993 |  818.4964 | 22.214286 | 236.17460 | ⋯ |  5 | 11 |  4 | 4 | 19 | 12 | 29 |  3 | 11 | 24 |\n",
       "| 4 | VLOG7 | Male   | 275.68 | 0.48758 | 0.1286000 | 1.23270 | 0.60069 | 1072.1004 | 16.947368 | 218.64580 | ⋯ | 12 | 22 | 11 | 7 | 12 | 15 | 21 | 11 |  9 | 16 |\n",
       "| 5 | VLOG8 | Female | 255.58 | 0.42310 | 0.0320580 | 1.62360 | 0.46439 |  669.6957 |  7.404762 |  21.80778 | ⋯ |  3 | 12 |  2 | 6 |  7 |  5 | 12 |  4 |  3 |  9 |\n",
       "| 6 | VLOG9 | Female | 230.75 | 0.22081 | 0.0014254 | 1.53720 | 0.67458 | 1294.1386 | 14.311475 | 130.88470 | ⋯ |  9 | 17 |  8 | 8 | 15 | 18 | 30 |  5 | 11 | 21 |\n",
       "\n"
      ],
      "text/plain": [
       "  vlogId gender mean.pitch sd.pitch mean.energy sd.energy time.speaking\n",
       "1 VLOG3  Female 239.32     0.36474  0.0021029   1.28980   0.51374      \n",
       "2 VLOG5  Male   173.50     0.47636  0.0031128   2.04870   0.70205      \n",
       "3 VLOG6  Male   201.28     0.27454  0.0321370   0.97954   0.75993      \n",
       "4 VLOG7  Male   275.68     0.48758  0.1286000   1.23270   0.60069      \n",
       "5 VLOG8  Female 255.58     0.42310  0.0320580   1.62360   0.46439      \n",
       "6 VLOG9  Female 230.75     0.22081  0.0014254   1.53720   0.67458      \n",
       "  speech_pace mean_words_sent var_words_sent ⋯ nrc_anger nrc_anticipation\n",
       "1  729.9412   18.750000       182.82895      ⋯  1        11              \n",
       "2  562.6380   19.750000       253.88158      ⋯  1         6              \n",
       "3  818.4964   22.214286       236.17460      ⋯  5        11              \n",
       "4 1072.1004   16.947368       218.64580      ⋯ 12        22              \n",
       "5  669.6957    7.404762        21.80778      ⋯  3        12              \n",
       "6 1294.1386   14.311475       130.88470      ⋯  9        17              \n",
       "  nrc_disgust nrc_fear nrc_joy nrc_negative nrc_positive nrc_sadness\n",
       "1  2          2         7       2           10            4         \n",
       "2  1          2         4       1           10            1         \n",
       "3  4          4        19      12           29            3         \n",
       "4 11          7        12      15           21           11         \n",
       "5  2          6         7       5           12            4         \n",
       "6  8          8        15      18           30            5         \n",
       "  nrc_surprise nrc_trust\n",
       "1  6            9       \n",
       "2  4            5       \n",
       "3 11           24       \n",
       "4  9           16       \n",
       "5  3            9       \n",
       "6 11           21       "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>\n",
       ".list-inline {list-style: none; margin:0; padding: 0}\n",
       ".list-inline>li {display: inline-block}\n",
       ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "</style>\n",
       "<ol class=list-inline><li>'vlogId'</li><li>'gender'</li><li>'mean.pitch'</li><li>'sd.pitch'</li><li>'mean.energy'</li><li>'sd.energy'</li><li>'time.speaking'</li><li>'speech_pace'</li><li>'mean_words_sent'</li><li>'var_words_sent'</li><li>'perc_quest'</li><li>'first_vs_second'</li><li>'self_vs_we'</li><li>'third_vs_other'</li><li>'perc_swear'</li><li>'perc_filler_words'</li><li>'nrc_anger'</li><li>'nrc_anticipation'</li><li>'nrc_disgust'</li><li>'nrc_fear'</li><li>'nrc_joy'</li><li>'nrc_negative'</li><li>'nrc_positive'</li><li>'nrc_sadness'</li><li>'nrc_surprise'</li><li>'nrc_trust'</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 'vlogId'\n",
       "\\item 'gender'\n",
       "\\item 'mean.pitch'\n",
       "\\item 'sd.pitch'\n",
       "\\item 'mean.energy'\n",
       "\\item 'sd.energy'\n",
       "\\item 'time.speaking'\n",
       "\\item 'speech\\_pace'\n",
       "\\item 'mean\\_words\\_sent'\n",
       "\\item 'var\\_words\\_sent'\n",
       "\\item 'perc\\_quest'\n",
       "\\item 'first\\_vs\\_second'\n",
       "\\item 'self\\_vs\\_we'\n",
       "\\item 'third\\_vs\\_other'\n",
       "\\item 'perc\\_swear'\n",
       "\\item 'perc\\_filler\\_words'\n",
       "\\item 'nrc\\_anger'\n",
       "\\item 'nrc\\_anticipation'\n",
       "\\item 'nrc\\_disgust'\n",
       "\\item 'nrc\\_fear'\n",
       "\\item 'nrc\\_joy'\n",
       "\\item 'nrc\\_negative'\n",
       "\\item 'nrc\\_positive'\n",
       "\\item 'nrc\\_sadness'\n",
       "\\item 'nrc\\_surprise'\n",
       "\\item 'nrc\\_trust'\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 'vlogId'\n",
       "2. 'gender'\n",
       "3. 'mean.pitch'\n",
       "4. 'sd.pitch'\n",
       "5. 'mean.energy'\n",
       "6. 'sd.energy'\n",
       "7. 'time.speaking'\n",
       "8. 'speech_pace'\n",
       "9. 'mean_words_sent'\n",
       "10. 'var_words_sent'\n",
       "11. 'perc_quest'\n",
       "12. 'first_vs_second'\n",
       "13. 'self_vs_we'\n",
       "14. 'third_vs_other'\n",
       "15. 'perc_swear'\n",
       "16. 'perc_filler_words'\n",
       "17. 'nrc_anger'\n",
       "18. 'nrc_anticipation'\n",
       "19. 'nrc_disgust'\n",
       "20. 'nrc_fear'\n",
       "21. 'nrc_joy'\n",
       "22. 'nrc_negative'\n",
       "23. 'nrc_positive'\n",
       "24. 'nrc_sadness'\n",
       "25. 'nrc_surprise'\n",
       "26. 'nrc_trust'\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       " [1] \"vlogId\"            \"gender\"            \"mean.pitch\"       \n",
       " [4] \"sd.pitch\"          \"mean.energy\"       \"sd.energy\"        \n",
       " [7] \"time.speaking\"     \"speech_pace\"       \"mean_words_sent\"  \n",
       "[10] \"var_words_sent\"    \"perc_quest\"        \"first_vs_second\"  \n",
       "[13] \"self_vs_we\"        \"third_vs_other\"    \"perc_swear\"       \n",
       "[16] \"perc_filler_words\" \"nrc_anger\"         \"nrc_anticipation\" \n",
       "[19] \"nrc_disgust\"       \"nrc_fear\"          \"nrc_joy\"          \n",
       "[22] \"nrc_negative\"      \"nrc_positive\"      \"nrc_sadness\"      \n",
       "[25] \"nrc_surprise\"      \"nrc_trust\"        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# left join all features into features_df\n",
    "features_df <- vlogger_df %>% \n",
    "        dplyr::select(vlogId, gender) %>%\n",
    "  left_join(stats_audiovisual, by = \"vlogId\") %>% \n",
    "  left_join(stats_sent_str, by = \"vlogId\") %>% \n",
    "  left_join(stats_spec_words, by = \"vlogId\") %>% \n",
    "  left_join(transcript_sentiment_count, by = \"vlogId\") \n",
    "\n",
    "# peek at df to verify successful merge\n",
    "head(features_df, 6)\n",
    "names(features_df)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "acb0cc95",
   "metadata": {
    "papermill": {
     "duration": 0.018506,
     "end_time": "2023-12-10T23:27:06.008856",
     "exception": false,
     "start_time": "2023-12-10T23:27:05.990350",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.5.2 Merge with response data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "id": "55de9d65",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:06.050253Z",
     "iopub.status.busy": "2023-12-10T23:27:06.048444Z",
     "iopub.status.idle": "2023-12-10T23:27:06.106301Z",
     "shell.execute_reply": "2023-12-10T23:27:06.104458Z"
    },
    "papermill": {
     "duration": 0.081375,
     "end_time": "2023-12-10T23:27:06.108944",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.027569",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A data.frame: 6 × 31</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>vlogId</th><th scope=col>gender</th><th scope=col>Extr</th><th scope=col>Agr</th><th scope=col>Cons</th><th scope=col>Emot</th><th scope=col>Open</th><th scope=col>mean.pitch</th><th scope=col>sd.pitch</th><th scope=col>mean.energy</th><th scope=col>⋯</th><th scope=col>nrc_anger</th><th scope=col>nrc_anticipation</th><th scope=col>nrc_disgust</th><th scope=col>nrc_fear</th><th scope=col>nrc_joy</th><th scope=col>nrc_negative</th><th scope=col>nrc_positive</th><th scope=col>nrc_sadness</th><th scope=col>nrc_surprise</th><th scope=col>nrc_trust</th></tr>\n",
       "\t<tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>1</th><td>VLOG3</td><td>Female</td><td>5.0</td><td>5.0</td><td>4.6</td><td>5.3</td><td>4.4</td><td>239.32</td><td>0.36474</td><td>0.0021029</td><td>⋯</td><td> 1</td><td>11</td><td> 2</td><td>2</td><td> 7</td><td> 2</td><td>10</td><td> 4</td><td> 6</td><td> 9</td></tr>\n",
       "\t<tr><th scope=row>2</th><td>VLOG5</td><td>Male  </td><td>5.9</td><td>5.3</td><td>5.3</td><td>5.8</td><td>5.5</td><td>173.50</td><td>0.47636</td><td>0.0031128</td><td>⋯</td><td> 1</td><td> 6</td><td> 1</td><td>2</td><td> 4</td><td> 1</td><td>10</td><td> 1</td><td> 4</td><td> 5</td></tr>\n",
       "\t<tr><th scope=row>3</th><td>VLOG6</td><td>Male  </td><td>5.4</td><td>4.8</td><td>4.4</td><td>4.8</td><td>5.7</td><td>201.28</td><td>0.27454</td><td>0.0321370</td><td>⋯</td><td> 5</td><td>11</td><td> 4</td><td>4</td><td>19</td><td>12</td><td>29</td><td> 3</td><td>11</td><td>24</td></tr>\n",
       "\t<tr><th scope=row>4</th><td>VLOG7</td><td>Male  </td><td>4.7</td><td>5.1</td><td>4.4</td><td>5.1</td><td>4.7</td><td>275.68</td><td>0.48758</td><td>0.1286000</td><td>⋯</td><td>12</td><td>22</td><td>11</td><td>7</td><td>12</td><td>15</td><td>21</td><td>11</td><td> 9</td><td>16</td></tr>\n",
       "\t<tr><th scope=row>5</th><td>VLOG8</td><td>Female</td><td> NA</td><td> NA</td><td> NA</td><td> NA</td><td> NA</td><td>255.58</td><td>0.42310</td><td>0.0320580</td><td>⋯</td><td> 3</td><td>12</td><td> 2</td><td>6</td><td> 7</td><td> 5</td><td>12</td><td> 4</td><td> 3</td><td> 9</td></tr>\n",
       "\t<tr><th scope=row>6</th><td>VLOG9</td><td>Female</td><td>5.6</td><td>5.0</td><td>4.0</td><td>4.2</td><td>4.9</td><td>230.75</td><td>0.22081</td><td>0.0014254</td><td>⋯</td><td> 9</td><td>17</td><td> 8</td><td>8</td><td>15</td><td>18</td><td>30</td><td> 5</td><td>11</td><td>21</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A data.frame: 6 × 31\n",
       "\\begin{tabular}{r|lllllllllllllllllllll}\n",
       "  & vlogId & gender & Extr & Agr & Cons & Emot & Open & mean.pitch & sd.pitch & mean.energy & ⋯ & nrc\\_anger & nrc\\_anticipation & nrc\\_disgust & nrc\\_fear & nrc\\_joy & nrc\\_negative & nrc\\_positive & nrc\\_sadness & nrc\\_surprise & nrc\\_trust\\\\\n",
       "  & <chr> & <chr> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & ⋯ & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int> & <int>\\\\\n",
       "\\hline\n",
       "\t1 & VLOG3 & Female & 5.0 & 5.0 & 4.6 & 5.3 & 4.4 & 239.32 & 0.36474 & 0.0021029 & ⋯ &  1 & 11 &  2 & 2 &  7 &  2 & 10 &  4 &  6 &  9\\\\\n",
       "\t2 & VLOG5 & Male   & 5.9 & 5.3 & 5.3 & 5.8 & 5.5 & 173.50 & 0.47636 & 0.0031128 & ⋯ &  1 &  6 &  1 & 2 &  4 &  1 & 10 &  1 &  4 &  5\\\\\n",
       "\t3 & VLOG6 & Male   & 5.4 & 4.8 & 4.4 & 4.8 & 5.7 & 201.28 & 0.27454 & 0.0321370 & ⋯ &  5 & 11 &  4 & 4 & 19 & 12 & 29 &  3 & 11 & 24\\\\\n",
       "\t4 & VLOG7 & Male   & 4.7 & 5.1 & 4.4 & 5.1 & 4.7 & 275.68 & 0.48758 & 0.1286000 & ⋯ & 12 & 22 & 11 & 7 & 12 & 15 & 21 & 11 &  9 & 16\\\\\n",
       "\t5 & VLOG8 & Female &  NA &  NA &  NA &  NA &  NA & 255.58 & 0.42310 & 0.0320580 & ⋯ &  3 & 12 &  2 & 6 &  7 &  5 & 12 &  4 &  3 &  9\\\\\n",
       "\t6 & VLOG9 & Female & 5.6 & 5.0 & 4.0 & 4.2 & 4.9 & 230.75 & 0.22081 & 0.0014254 & ⋯ &  9 & 17 &  8 & 8 & 15 & 18 & 30 &  5 & 11 & 21\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A data.frame: 6 × 31\n",
       "\n",
       "| <!--/--> | vlogId &lt;chr&gt; | gender &lt;chr&gt; | Extr &lt;dbl&gt; | Agr &lt;dbl&gt; | Cons &lt;dbl&gt; | Emot &lt;dbl&gt; | Open &lt;dbl&gt; | mean.pitch &lt;dbl&gt; | sd.pitch &lt;dbl&gt; | mean.energy &lt;dbl&gt; | ⋯ ⋯ | nrc_anger &lt;int&gt; | nrc_anticipation &lt;int&gt; | nrc_disgust &lt;int&gt; | nrc_fear &lt;int&gt; | nrc_joy &lt;int&gt; | nrc_negative &lt;int&gt; | nrc_positive &lt;int&gt; | nrc_sadness &lt;int&gt; | nrc_surprise &lt;int&gt; | nrc_trust &lt;int&gt; |\n",
       "|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|\n",
       "| 1 | VLOG3 | Female | 5.0 | 5.0 | 4.6 | 5.3 | 4.4 | 239.32 | 0.36474 | 0.0021029 | ⋯ |  1 | 11 |  2 | 2 |  7 |  2 | 10 |  4 |  6 |  9 |\n",
       "| 2 | VLOG5 | Male   | 5.9 | 5.3 | 5.3 | 5.8 | 5.5 | 173.50 | 0.47636 | 0.0031128 | ⋯ |  1 |  6 |  1 | 2 |  4 |  1 | 10 |  1 |  4 |  5 |\n",
       "| 3 | VLOG6 | Male   | 5.4 | 4.8 | 4.4 | 4.8 | 5.7 | 201.28 | 0.27454 | 0.0321370 | ⋯ |  5 | 11 |  4 | 4 | 19 | 12 | 29 |  3 | 11 | 24 |\n",
       "| 4 | VLOG7 | Male   | 4.7 | 5.1 | 4.4 | 5.1 | 4.7 | 275.68 | 0.48758 | 0.1286000 | ⋯ | 12 | 22 | 11 | 7 | 12 | 15 | 21 | 11 |  9 | 16 |\n",
       "| 5 | VLOG8 | Female |  NA |  NA |  NA |  NA |  NA | 255.58 | 0.42310 | 0.0320580 | ⋯ |  3 | 12 |  2 | 6 |  7 |  5 | 12 |  4 |  3 |  9 |\n",
       "| 6 | VLOG9 | Female | 5.6 | 5.0 | 4.0 | 4.2 | 4.9 | 230.75 | 0.22081 | 0.0014254 | ⋯ |  9 | 17 |  8 | 8 | 15 | 18 | 30 |  5 | 11 | 21 |\n",
       "\n"
      ],
      "text/plain": [
       "  vlogId gender Extr Agr Cons Emot Open mean.pitch sd.pitch mean.energy ⋯\n",
       "1 VLOG3  Female 5.0  5.0 4.6  5.3  4.4  239.32     0.36474  0.0021029   ⋯\n",
       "2 VLOG5  Male   5.9  5.3 5.3  5.8  5.5  173.50     0.47636  0.0031128   ⋯\n",
       "3 VLOG6  Male   5.4  4.8 4.4  4.8  5.7  201.28     0.27454  0.0321370   ⋯\n",
       "4 VLOG7  Male   4.7  5.1 4.4  5.1  4.7  275.68     0.48758  0.1286000   ⋯\n",
       "5 VLOG8  Female  NA   NA  NA   NA   NA  255.58     0.42310  0.0320580   ⋯\n",
       "6 VLOG9  Female 5.6  5.0 4.0  4.2  4.9  230.75     0.22081  0.0014254   ⋯\n",
       "  nrc_anger nrc_anticipation nrc_disgust nrc_fear nrc_joy nrc_negative\n",
       "1  1        11                2          2         7       2          \n",
       "2  1         6                1          2         4       1          \n",
       "3  5        11                4          4        19      12          \n",
       "4 12        22               11          7        12      15          \n",
       "5  3        12                2          6         7       5          \n",
       "6  9        17                8          8        15      18          \n",
       "  nrc_positive nrc_sadness nrc_surprise nrc_trust\n",
       "1 10            4           6            9       \n",
       "2 10            1           4            5       \n",
       "3 29            3          11           24       \n",
       "4 21           11           9           16       \n",
       "5 12            4           3            9       \n",
       "6 30            5          11           21       "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>\n",
       ".list-inline {list-style: none; margin:0; padding: 0}\n",
       ".list-inline>li {display: inline-block}\n",
       ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "</style>\n",
       "<ol class=list-inline><li>403</li><li>31</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 403\n",
       "\\item 31\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 403\n",
       "2. 31\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 403  31"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "vlogger_total_df <- vlogger_df %>% \n",
    "    left_join(features_df, by = c(\"vlogId\", \"gender\"))\n",
    "head(vlogger_total_df)\n",
    "dim(vlogger_total_df)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2e9e332c",
   "metadata": {
    "papermill": {
     "duration": 0.019555,
     "end_time": "2023-12-10T23:27:06.148451",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.128896",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 2.5.3 Split dataset into training and test data\n",
    "\n",
    "Next, we split our dataset into training and testing sets. The training set will be used to develop our models, while the test data contains vloggers with missing personality impression scores, which we use to test our models and assess their performance."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 16,
   "id": "f0444aba",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:06.191537Z",
     "iopub.status.busy": "2023-12-10T23:27:06.189833Z",
     "iopub.status.idle": "2023-12-10T23:27:06.226141Z",
     "shell.execute_reply": "2023-12-10T23:27:06.224110Z"
    },
    "papermill": {
     "duration": 0.060476,
     "end_time": "2023-12-10T23:27:06.228792",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.168316",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<style>\n",
       ".list-inline {list-style: none; margin:0; padding: 0}\n",
       ".list-inline>li {display: inline-block}\n",
       ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "</style>\n",
       "<ol class=list-inline><li>80</li><li>31</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 80\n",
       "\\item 31\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 80\n",
       "2. 31\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 80 31"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>\n",
       ".list-inline {list-style: none; margin:0; padding: 0}\n",
       ".list-inline>li {display: inline-block}\n",
       ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "</style>\n",
       "<ol class=list-inline><li>323</li><li>31</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 323\n",
       "\\item 31\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 323\n",
       "2. 31\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 323  31"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# test data contains vloggers with missing extraversion scores (etc.)\n",
    "test_data <- vlogger_total_df %>%\n",
    "    filter(is.na(Extr))\n",
    "# training data contains vloggers including extraversion scores\n",
    "training_data <- vlogger_total_df %>%\n",
    "    filter(!is.na(Extr))\n",
    "\n",
    "# peek at df dimensions\n",
    "dim(test_data)\n",
    "dim(training_data)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "3da6abc9",
   "metadata": {
    "papermill": {
     "duration": 0.019572,
     "end_time": "2023-12-10T23:27:06.268314",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.248742",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# 3. Model selection"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "57bba344",
   "metadata": {
    "papermill": {
     "duration": 0.019588,
     "end_time": "2023-12-10T23:27:06.307356",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.287768",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.1 Predictive model: Full model\n",
    "\n",
    "*In this section, we fit our model with all predictors. We looked at the R²  and the adjusted R² to have an indication of how good the prediction is. After that, searched for the predictors that are not significant in any of the Big5 dimensions.*"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 17,
   "id": "0f4bcf09",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:06.351241Z",
     "iopub.status.busy": "2023-12-10T23:27:06.349600Z",
     "iopub.status.idle": "2023-12-10T23:27:06.464189Z",
     "shell.execute_reply": "2023-12-10T23:27:06.459660Z"
    },
    "papermill": {
     "duration": 0.141825,
     "end_time": "2023-12-10T23:27:06.469428",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.327603",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Response Extr :\n",
       "\n",
       "Call:\n",
       "lm(formula = Extr ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
       "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
       "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
       "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.54108 -0.60873  0.06816  0.62176  1.87297 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        2.777e+00  6.378e-01   4.354 1.84e-05 ***\n",
       "genderMale         2.213e-01  1.329e-01   1.666 0.096761 .  \n",
       "mean.pitch         2.966e-03  1.047e-03   2.834 0.004912 ** \n",
       "sd.pitch          -6.757e-01  4.450e-01  -1.519 0.129918    \n",
       "mean.energy        5.596e+00  2.277e+00   2.458 0.014544 *  \n",
       "sd.energy          2.030e-01  8.502e-02   2.388 0.017565 *  \n",
       "time.speaking      1.869e+00  4.018e-01   4.652 4.95e-06 ***\n",
       "speech_pace        4.621e-05  5.060e-05   0.913 0.361825    \n",
       "mean_words_sent   -5.121e-03  1.275e-02  -0.402 0.688334    \n",
       "var_words_sent    -1.439e-05  2.802e-04  -0.051 0.959073    \n",
       "perc_quest         6.364e+02  1.914e+02   3.324 0.000997 ***\n",
       "first_vs_second   -3.109e-01  3.313e-01  -0.938 0.348777    \n",
       "self_vs_we         1.954e-02  3.786e-01   0.052 0.958870    \n",
       "third_vs_other     1.082e-01  2.651e-01   0.408 0.683349    \n",
       "perc_swear         9.693e+00  6.147e+00   1.577 0.115934    \n",
       "perc_filler_words -5.949e+00  2.038e+00  -2.919 0.003784 ** \n",
       "nrc_anger          1.054e-02  1.994e-02   0.529 0.597479    \n",
       "nrc_anticipation  -1.338e-02  1.116e-02  -1.199 0.231517    \n",
       "nrc_disgust        3.895e-03  2.004e-02   0.194 0.846019    \n",
       "nrc_fear           3.885e-03  1.562e-02   0.249 0.803769    \n",
       "nrc_joy            2.929e-02  1.396e-02   2.097 0.036804 *  \n",
       "nrc_negative      -3.611e-03  1.465e-02  -0.246 0.805480    \n",
       "nrc_positive      -4.570e-04  9.593e-03  -0.048 0.962036    \n",
       "nrc_sadness       -3.276e-02  1.755e-02  -1.867 0.062937 .  \n",
       "nrc_surprise       9.953e-03  1.755e-02   0.567 0.571105    \n",
       "nrc_trust         -1.137e-02  1.281e-02  -0.888 0.375377    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.8753 on 297 degrees of freedom\n",
       "Multiple R-squared:  0.2449,\tAdjusted R-squared:  0.1813 \n",
       "F-statistic: 3.853 on 25 and 297 DF,  p-value: 1.037e-08\n",
       "\n",
       "\n",
       "Response Agr :\n",
       "\n",
       "Call:\n",
       "lm(formula = Agr ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
       "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
       "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
       "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.63412 -0.37907  0.05506  0.45006  1.96280 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        5.211e+00  5.360e-01   9.724  < 2e-16 ***\n",
       "genderMale        -4.417e-01  1.116e-01  -3.956 9.52e-05 ***\n",
       "mean.pitch        -3.123e-04  8.796e-04  -0.355   0.7228    \n",
       "sd.pitch          -1.198e-01  3.739e-01  -0.320   0.7489    \n",
       "mean.energy        9.121e-01  1.913e+00   0.477   0.6339    \n",
       "sd.energy         -7.266e-02  7.145e-02  -1.017   0.3100    \n",
       "time.speaking      2.196e-01  3.376e-01   0.650   0.5159    \n",
       "speech_pace        6.019e-05  4.252e-05   1.416   0.1579    \n",
       "mean_words_sent    2.066e-02  1.072e-02   1.928   0.0548 .  \n",
       "var_words_sent    -2.985e-04  2.355e-04  -1.268   0.2059    \n",
       "perc_quest        -2.868e+01  1.609e+02  -0.178   0.8586    \n",
       "first_vs_second   -2.908e-01  2.784e-01  -1.045   0.2970    \n",
       "self_vs_we        -1.037e-01  3.181e-01  -0.326   0.7448    \n",
       "third_vs_other    -5.525e-01  2.227e-01  -2.480   0.0137 *  \n",
       "perc_swear        -2.196e+01  5.166e+00  -4.252 2.85e-05 ***\n",
       "perc_filler_words  3.274e+00  1.713e+00   1.911   0.0569 .  \n",
       "nrc_anger         -4.118e-02  1.675e-02  -2.458   0.0145 *  \n",
       "nrc_anticipation  -8.914e-03  9.376e-03  -0.951   0.3426    \n",
       "nrc_disgust       -6.736e-03  1.684e-02  -0.400   0.6895    \n",
       "nrc_fear           2.881e-02  1.313e-02   2.195   0.0290 *  \n",
       "nrc_joy            1.975e-02  1.173e-02   1.683   0.0934 .  \n",
       "nrc_negative      -1.628e-02  1.231e-02  -1.323   0.1869    \n",
       "nrc_positive       5.600e-03  8.061e-03   0.695   0.4878    \n",
       "nrc_sadness       -1.469e-02  1.475e-02  -0.996   0.3201    \n",
       "nrc_surprise       2.920e-02  1.475e-02   1.980   0.0486 *  \n",
       "nrc_trust         -1.931e-02  1.076e-02  -1.794   0.0738 .  \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7356 on 297 degrees of freedom\n",
       "Multiple R-squared:  0.3715,\tAdjusted R-squared:  0.3186 \n",
       "F-statistic: 7.022 on 25 and 297 DF,  p-value: < 2.2e-16\n",
       "\n",
       "\n",
       "Response Cons :\n",
       "\n",
       "Call:\n",
       "lm(formula = Cons ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
       "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
       "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
       "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.27736 -0.38234  0.02317  0.46633  1.70384 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.740e+00  5.170e-01   9.169  < 2e-16 ***\n",
       "genderMale        -7.749e-02  1.077e-01  -0.720 0.472372    \n",
       "mean.pitch        -1.014e-03  8.484e-04  -1.196 0.232825    \n",
       "sd.pitch          -3.871e-01  3.607e-01  -1.073 0.284063    \n",
       "mean.energy       -6.884e-01  1.846e+00  -0.373 0.709393    \n",
       "sd.energy         -3.745e-02  6.892e-02  -0.543 0.587198    \n",
       "time.speaking      1.120e+00  3.256e-01   3.440 0.000665 ***\n",
       "speech_pace        6.921e-05  4.101e-05   1.687 0.092558 .  \n",
       "mean_words_sent    2.911e-02  1.034e-02   2.816 0.005192 ** \n",
       "var_words_sent    -6.234e-04  2.271e-04  -2.745 0.006424 ** \n",
       "perc_quest        -2.573e+02  1.552e+02  -1.658 0.098309 .  \n",
       "first_vs_second   -5.541e-01  2.685e-01  -2.064 0.039920 *  \n",
       "self_vs_we        -5.044e-01  3.069e-01  -1.644 0.101312    \n",
       "third_vs_other     8.352e-02  2.149e-01   0.389 0.697770    \n",
       "perc_swear        -7.535e-01  4.983e+00  -0.151 0.879909    \n",
       "perc_filler_words -6.147e-01  1.652e+00  -0.372 0.710106    \n",
       "nrc_anger         -3.827e-02  1.616e-02  -2.368 0.018538 *  \n",
       "nrc_anticipation  -1.398e-02  9.044e-03  -1.546 0.123209    \n",
       "nrc_disgust       -2.436e-02  1.624e-02  -1.499 0.134842    \n",
       "nrc_fear           3.253e-02  1.266e-02   2.569 0.010690 *  \n",
       "nrc_joy           -1.485e-02  1.132e-02  -1.312 0.190516    \n",
       "nrc_negative      -1.114e-02  1.187e-02  -0.939 0.348723    \n",
       "nrc_positive       2.387e-02  7.776e-03   3.070 0.002336 ** \n",
       "nrc_sadness        1.717e-02  1.423e-02   1.207 0.228385    \n",
       "nrc_surprise       1.957e-02  1.423e-02   1.375 0.170019    \n",
       "nrc_trust         -9.467e-03  1.038e-02  -0.912 0.362661    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7095 on 297 degrees of freedom\n",
       "Multiple R-squared:  0.2552,\tAdjusted R-squared:  0.1925 \n",
       "F-statistic:  4.07 on 25 and 297 DF,  p-value: 2.143e-09\n",
       "\n",
       "\n",
       "Response Emot :\n",
       "\n",
       "Call:\n",
       "lm(formula = Emot ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
       "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
       "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
       "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.19306 -0.41366  0.04688  0.45286  1.69063 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.921e+00  5.249e-01   9.376  < 2e-16 ***\n",
       "genderMale        -1.854e-01  1.093e-01  -1.696  0.09102 .  \n",
       "mean.pitch        -5.975e-04  8.614e-04  -0.694  0.48846    \n",
       "sd.pitch          -2.202e-02  3.662e-01  -0.060  0.95209    \n",
       "mean.energy        1.540e+00  1.874e+00   0.822  0.41169    \n",
       "sd.energy          5.738e-03  6.997e-02   0.082  0.93469    \n",
       "time.speaking      3.529e-01  3.306e-01   1.068  0.28660    \n",
       "speech_pace        4.162e-05  4.164e-05   1.000  0.31831    \n",
       "mean_words_sent    2.178e-02  1.050e-02   2.075  0.03883 *  \n",
       "var_words_sent    -4.745e-04  2.306e-04  -2.058  0.04047 *  \n",
       "perc_quest         1.252e+02  1.575e+02   0.795  0.42748    \n",
       "first_vs_second   -2.567e-01  2.726e-01  -0.942  0.34721    \n",
       "self_vs_we        -2.183e-01  3.115e-01  -0.701  0.48395    \n",
       "third_vs_other    -2.025e-01  2.181e-01  -0.929  0.35387    \n",
       "perc_swear        -1.478e+01  5.059e+00  -2.922  0.00374 ** \n",
       "perc_filler_words  1.644e+00  1.677e+00   0.980  0.32791    \n",
       "nrc_anger         -2.315e-02  1.641e-02  -1.411  0.15938    \n",
       "nrc_anticipation  -1.447e-02  9.182e-03  -1.576  0.11612    \n",
       "nrc_disgust       -6.076e-03  1.649e-02  -0.368  0.71281    \n",
       "nrc_fear           1.854e-02  1.285e-02   1.443  0.15018    \n",
       "nrc_joy            4.806e-03  1.149e-02   0.418  0.67607    \n",
       "nrc_negative      -1.138e-02  1.205e-02  -0.944  0.34592    \n",
       "nrc_positive       1.165e-02  7.894e-03   1.476  0.14095    \n",
       "nrc_sadness       -1.629e-02  1.444e-02  -1.128  0.26042    \n",
       "nrc_surprise       2.327e-02  1.444e-02   1.611  0.10829    \n",
       "nrc_trust         -6.188e-03  1.054e-02  -0.587  0.55768    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7203 on 297 degrees of freedom\n",
       "Multiple R-squared:  0.196,\tAdjusted R-squared:  0.1283 \n",
       "F-statistic: 2.896 on 25 and 297 DF,  p-value: 9.84e-06\n",
       "\n",
       "\n",
       "Response Open :\n",
       "\n",
       "Call:\n",
       "lm(formula = Open ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
       "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
       "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
       "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.67502 -0.42957  0.02485  0.42329  1.65808 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        3.626e+00  5.065e-01   7.159 6.41e-12 ***\n",
       "genderMale         2.056e-01  1.055e-01   1.949   0.0523 .  \n",
       "mean.pitch         1.360e-03  8.313e-04   1.635   0.1030    \n",
       "sd.pitch          -3.733e-01  3.534e-01  -1.056   0.2916    \n",
       "mean.energy        1.387e+00  1.808e+00   0.767   0.4437    \n",
       "sd.energy          8.012e-02  6.752e-02   1.187   0.2363    \n",
       "time.speaking      4.663e-01  3.191e-01   1.461   0.1450    \n",
       "speech_pace       -8.957e-06  4.018e-05  -0.223   0.8238    \n",
       "mean_words_sent    1.557e-02  1.013e-02   1.537   0.1252    \n",
       "var_words_sent    -1.710e-04  2.225e-04  -0.768   0.4429    \n",
       "perc_quest         2.650e+02  1.520e+02   1.743   0.0823 .  \n",
       "first_vs_second    4.916e-04  2.631e-01   0.002   0.9985    \n",
       "self_vs_we         2.581e-01  3.007e-01   0.858   0.3913    \n",
       "third_vs_other    -1.612e-01  2.105e-01  -0.766   0.4446    \n",
       "perc_swear        -6.203e+00  4.882e+00  -1.271   0.2049    \n",
       "perc_filler_words -3.096e+00  1.619e+00  -1.912   0.0568 .  \n",
       "nrc_anger          1.828e-03  1.583e-02   0.115   0.9082    \n",
       "nrc_anticipation  -1.463e-02  8.862e-03  -1.651   0.0999 .  \n",
       "nrc_disgust        7.717e-03  1.592e-02   0.485   0.6281    \n",
       "nrc_fear          -1.724e-03  1.241e-02  -0.139   0.8896    \n",
       "nrc_joy            2.380e-02  1.109e-02   2.146   0.0327 *  \n",
       "nrc_negative      -5.532e-03  1.163e-02  -0.475   0.6348    \n",
       "nrc_positive       4.893e-03  7.619e-03   0.642   0.5212    \n",
       "nrc_sadness       -1.529e-02  1.394e-02  -1.097   0.2735    \n",
       "nrc_surprise      -7.230e-03  1.394e-02  -0.519   0.6044    \n",
       "nrc_trust         -7.695e-03  1.017e-02  -0.756   0.4501    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.6952 on 297 degrees of freedom\n",
       "Multiple R-squared:  0.1137,\tAdjusted R-squared:  0.03909 \n",
       "F-statistic: 1.524 on 25 and 297 DF,  p-value: 0.05513\n",
       "\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# full model (all predictors)\n",
    "full_model <- lm(cbind(Extr, Agr, Cons, Emot, Open) ~ .,\n",
    "  data = training_data[, -1]\n",
    ")\n",
    "summary(full_model)\n",
    "# adjust R² scores:\n",
    "#  E 0.1873\n",
    "#  A 0.3204\n",
    "#  C 0.1891\n",
    "#  E 0.1265\n",
    "#  O 0.0379\n",
    "\n",
    "# sd.pitch, speech_pace, nrc_disgust, self_we, nrc_anticipation were not \n",
    "# significant predictors for any of the dimensions"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "63117b46",
   "metadata": {
    "papermill": {
     "duration": 0.024003,
     "end_time": "2023-12-10T23:27:06.535913",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.511910",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.2 Predictive model: Adjusted model \n",
    "\n",
    "In this section we excluded all the predictors that were not significant in any of the Big5 dimensions. The adjust R² improved slightly for  agreeableness and emotional stability. However the adjust R² decreased for extroversion and conscientiousness. The anova was not significant. In other words, the second model does not predict better than the full model. However, it is a simpler model and if two model predict the same it is always better to choose the simpler model. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 18,
   "id": "94beaadb",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:06.581059Z",
     "iopub.status.busy": "2023-12-10T23:27:06.579164Z",
     "iopub.status.idle": "2023-12-10T23:27:06.738961Z",
     "shell.execute_reply": "2023-12-10T23:27:06.731585Z"
    },
    "papermill": {
     "duration": 0.189108,
     "end_time": "2023-12-10T23:27:06.745265",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.556157",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Response Extr :\n",
       "\n",
       "Call:\n",
       "lm(formula = Extr ~ gender + mean.pitch + mean.energy + sd.energy + \n",
       "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
       "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
       "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
       "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.49114 -0.61248  0.05752  0.65075  1.87625 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        2.584e+00  4.701e-01   5.497 8.22e-08 ***\n",
       "genderMale         1.431e-01  1.121e-01   1.276 0.202858    \n",
       "mean.pitch         3.566e-03  9.952e-04   3.583 0.000396 ***\n",
       "mean.energy        5.343e+00  2.250e+00   2.375 0.018178 *  \n",
       "sd.energy          1.704e-01  8.332e-02   2.045 0.041744 *  \n",
       "time.speaking      1.740e+00  3.609e-01   4.822 2.26e-06 ***\n",
       "mean_words_sent   -6.392e-03  1.235e-02  -0.518 0.605048    \n",
       "var_words_sent     2.907e-06  2.765e-04   0.011 0.991618    \n",
       "perc_quest         6.251e+02  1.895e+02   3.298 0.001089 ** \n",
       "first_vs_second   -2.825e-01  3.261e-01  -0.866 0.386984    \n",
       "third_vs_other     1.073e-01  2.627e-01   0.408 0.683380    \n",
       "perc_swear         9.026e+00  5.798e+00   1.557 0.120591    \n",
       "perc_filler_words -6.302e+00  2.025e+00  -3.112 0.002034 ** \n",
       "nrc_anger          9.642e-03  1.984e-02   0.486 0.627255    \n",
       "nrc_fear          -8.718e-05  1.512e-02  -0.006 0.995404    \n",
       "nrc_joy            2.513e-02  1.352e-02   1.859 0.063985 .  \n",
       "nrc_negative       8.548e-04  1.338e-02   0.064 0.949098    \n",
       "nrc_positive      -5.031e-04  9.336e-03  -0.054 0.957056    \n",
       "nrc_sadness       -3.242e-02  1.720e-02  -1.885 0.060362 .  \n",
       "nrc_surprise       2.748e-03  1.596e-02   0.172 0.863410    \n",
       "nrc_trust         -1.356e-02  1.273e-02  -1.065 0.287651    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.8749 on 302 degrees of freedom\n",
       "Multiple R-squared:  0.2329,\tAdjusted R-squared:  0.1821 \n",
       "F-statistic: 4.584 on 20 and 302 DF,  p-value: 1.538e-09\n",
       "\n",
       "\n",
       "Response Agr :\n",
       "\n",
       "Call:\n",
       "lm(formula = Agr ~ gender + mean.pitch + mean.energy + sd.energy + \n",
       "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
       "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
       "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
       "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.65703 -0.38625  0.06751  0.46556  1.95931 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        5.159e+00  3.941e-01  13.091  < 2e-16 ***\n",
       "genderMale        -4.343e-01  9.397e-02  -4.622 5.65e-06 ***\n",
       "mean.pitch        -3.989e-05  8.343e-04  -0.048   0.9619    \n",
       "mean.energy        9.333e-01  1.886e+00   0.495   0.6211    \n",
       "sd.energy         -8.723e-02  6.985e-02  -1.249   0.2127    \n",
       "time.speaking      4.001e-02  3.026e-01   0.132   0.8949    \n",
       "mean_words_sent    2.094e-02  1.035e-02   2.023   0.0440 *  \n",
       "var_words_sent    -2.959e-04  2.318e-04  -1.277   0.2027    \n",
       "perc_quest        -4.335e+01  1.589e+02  -0.273   0.7851    \n",
       "first_vs_second   -3.039e-01  2.734e-01  -1.112   0.2671    \n",
       "third_vs_other    -5.548e-01  2.202e-01  -2.519   0.0123 *  \n",
       "perc_swear        -2.369e+01  4.861e+00  -4.875 1.76e-06 ***\n",
       "perc_filler_words  3.102e+00  1.698e+00   1.828   0.0686 .  \n",
       "nrc_anger         -4.201e-02  1.663e-02  -2.526   0.0120 *  \n",
       "nrc_fear           2.554e-02  1.268e-02   2.014   0.0448 *  \n",
       "nrc_joy            1.670e-02  1.133e-02   1.474   0.1415    \n",
       "nrc_negative      -1.471e-02  1.122e-02  -1.312   0.1907    \n",
       "nrc_positive       6.251e-03  7.826e-03   0.799   0.4250    \n",
       "nrc_sadness       -1.630e-02  1.442e-02  -1.131   0.2590    \n",
       "nrc_surprise       2.380e-02  1.338e-02   1.778   0.0764 .  \n",
       "nrc_trust         -2.015e-02  1.067e-02  -1.888   0.0600 .  \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7334 on 302 degrees of freedom\n",
       "Multiple R-squared:  0.3646,\tAdjusted R-squared:  0.3225 \n",
       "F-statistic: 8.665 on 20 and 302 DF,  p-value: < 2.2e-16\n",
       "\n",
       "\n",
       "Response Cons :\n",
       "\n",
       "Call:\n",
       "lm(formula = Cons ~ gender + mean.pitch + mean.energy + sd.energy + \n",
       "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
       "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
       "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
       "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.18678 -0.39468 -0.00893  0.52324  1.52872 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.229e+00  3.859e-01  10.959  < 2e-16 ***\n",
       "genderMale        -9.901e-02  9.200e-02  -1.076 0.282714    \n",
       "mean.pitch        -5.178e-04  8.169e-04  -0.634 0.526617    \n",
       "mean.energy       -8.800e-01  1.846e+00  -0.477 0.634007    \n",
       "sd.energy         -6.673e-02  6.839e-02  -0.976 0.329964    \n",
       "time.speaking      9.345e-01  2.962e-01   3.154 0.001770 ** \n",
       "mean_words_sent    3.114e-02  1.013e-02   3.073 0.002316 ** \n",
       "var_words_sent    -6.392e-04  2.269e-04  -2.817 0.005170 ** \n",
       "perc_quest        -2.760e+02  1.556e+02  -1.775 0.076978 .  \n",
       "first_vs_second   -6.251e-01  2.677e-01  -2.335 0.020183 *  \n",
       "third_vs_other     9.632e-02  2.156e-01   0.447 0.655428    \n",
       "perc_swear        -4.709e+00  4.759e+00  -0.990 0.323174    \n",
       "perc_filler_words -1.075e+00  1.662e+00  -0.647 0.518411    \n",
       "nrc_anger         -4.010e-02  1.628e-02  -2.463 0.014333 *  \n",
       "nrc_fear           2.976e-02  1.241e-02   2.398 0.017105 *  \n",
       "nrc_joy           -1.976e-02  1.109e-02  -1.781 0.075868 .  \n",
       "nrc_negative      -1.437e-02  1.098e-02  -1.309 0.191580    \n",
       "nrc_positive       2.558e-02  7.662e-03   3.339 0.000947 ***\n",
       "nrc_sadness        1.261e-02  1.412e-02   0.894 0.372260    \n",
       "nrc_surprise       9.863e-03  1.310e-02   0.753 0.452131    \n",
       "nrc_trust         -1.193e-02  1.045e-02  -1.142 0.254321    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7181 on 302 degrees of freedom\n",
       "Multiple R-squared:  0.2241,\tAdjusted R-squared:  0.1728 \n",
       "F-statistic: 4.362 on 20 and 302 DF,  p-value: 6.112e-09\n",
       "\n",
       "\n",
       "Response Emot :\n",
       "\n",
       "Call:\n",
       "lm(formula = Emot ~ gender + mean.pitch + mean.energy + sd.energy + \n",
       "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
       "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
       "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
       "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.17525 -0.42270  0.07106  0.48641  1.61800 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.764e+00  3.865e-01  12.326  < 2e-16 ***\n",
       "genderMale        -1.616e-01  9.215e-02  -1.754 0.080465 .  \n",
       "mean.pitch        -4.052e-04  8.182e-04  -0.495 0.620766    \n",
       "mean.energy        1.354e+00  1.849e+00   0.732 0.464578    \n",
       "sd.energy         -5.261e-03  6.850e-02  -0.077 0.938833    \n",
       "time.speaking      2.575e-01  2.967e-01   0.868 0.386221    \n",
       "mean_words_sent    2.158e-02  1.015e-02   2.126 0.034305 *  \n",
       "var_words_sent    -4.643e-04  2.273e-04  -2.043 0.041929 *  \n",
       "perc_quest         1.004e+02  1.558e+02   0.644 0.519802    \n",
       "first_vs_second   -2.935e-01  2.681e-01  -1.095 0.274461    \n",
       "third_vs_other    -1.792e-01  2.160e-01  -0.830 0.407382    \n",
       "perc_swear        -1.679e+01  4.766e+00  -3.523 0.000493 ***\n",
       "perc_filler_words  1.385e+00  1.665e+00   0.832 0.406194    \n",
       "nrc_anger         -2.290e-02  1.631e-02  -1.404 0.161221    \n",
       "nrc_fear           1.474e-02  1.243e-02   1.185 0.236805    \n",
       "nrc_joy           -3.275e-05  1.111e-02  -0.003 0.997650    \n",
       "nrc_negative      -1.065e-02  1.100e-02  -0.969 0.333517    \n",
       "nrc_positive       1.119e-02  7.674e-03   1.458 0.145789    \n",
       "nrc_sadness       -1.706e-02  1.414e-02  -1.207 0.228494    \n",
       "nrc_surprise       1.411e-02  1.312e-02   1.076 0.282970    \n",
       "nrc_trust         -7.335e-03  1.047e-02  -0.701 0.483920    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7192 on 302 degrees of freedom\n",
       "Multiple R-squared:  0.1849,\tAdjusted R-squared:  0.1309 \n",
       "F-statistic: 3.425 on 20 and 302 DF,  p-value: 1.99e-06\n",
       "\n",
       "\n",
       "Response Open :\n",
       "\n",
       "Call:\n",
       "lm(formula = Open ~ gender + mean.pitch + mean.energy + sd.energy + \n",
       "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
       "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
       "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
       "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.73718 -0.47863  0.01218  0.42915  1.62653 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        3.707e+00  3.734e-01   9.928   <2e-16 ***\n",
       "genderMale         1.556e-01  8.903e-02   1.748   0.0815 .  \n",
       "mean.pitch         1.590e-03  7.905e-04   2.011   0.0452 *  \n",
       "mean.energy        9.749e-01  1.787e+00   0.546   0.5857    \n",
       "sd.energy          6.546e-02  6.618e-02   0.989   0.3234    \n",
       "time.speaking      5.308e-01  2.867e-01   1.851   0.0651 .  \n",
       "mean_words_sent    1.160e-02  9.806e-03   1.183   0.2378    \n",
       "var_words_sent    -1.187e-04  2.196e-04  -0.540   0.5893    \n",
       "perc_quest         2.417e+02  1.505e+02   1.606   0.1094    \n",
       "first_vs_second    2.183e-02  2.590e-01   0.084   0.9329    \n",
       "third_vs_other    -1.437e-01  2.087e-01  -0.689   0.4916    \n",
       "perc_swear        -6.087e+00  4.605e+00  -1.322   0.1872    \n",
       "perc_filler_words -3.316e+00  1.608e+00  -2.061   0.0401 *  \n",
       "nrc_anger          2.466e-03  1.575e-02   0.157   0.8757    \n",
       "nrc_fear          -6.092e-03  1.201e-02  -0.507   0.6124    \n",
       "nrc_joy            1.971e-02  1.074e-02   1.835   0.0674 .  \n",
       "nrc_negative      -2.274e-03  1.063e-02  -0.214   0.8307    \n",
       "nrc_positive       2.436e-03  7.415e-03   0.329   0.7427    \n",
       "nrc_sadness       -1.306e-02  1.366e-02  -0.956   0.3398    \n",
       "nrc_surprise      -1.591e-02  1.268e-02  -1.255   0.2105    \n",
       "nrc_trust         -8.865e-03  1.011e-02  -0.877   0.3814    \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.6949 on 302 degrees of freedom\n",
       "Multiple R-squared:  0.09942,\tAdjusted R-squared:  0.03978 \n",
       "F-statistic: 1.667 on 20 and 302 DF,  p-value: 0.03776\n",
       "\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A anova: 2 × 8</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>Res.Df</th><th scope=col>Df</th><th scope=col>Gen.var.</th><th scope=col>Pillai</th><th scope=col>approx F</th><th scope=col>num Df</th><th scope=col>den Df</th><th scope=col>Pr(&gt;F)</th></tr>\n",
       "\t<tr><th></th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>1</th><td>297</td><td>NA</td><td>0.4276241</td><td>        NA</td><td>      NA</td><td>NA</td><td>  NA</td><td>       NA</td></tr>\n",
       "\t<tr><th scope=row>2</th><td>302</td><td> 5</td><td>0.4279837</td><td>0.08566022</td><td>1.035382</td><td>25</td><td>1485</td><td>0.4151172</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A anova: 2 × 8\n",
       "\\begin{tabular}{r|llllllll}\n",
       "  & Res.Df & Df & Gen.var. & Pillai & approx F & num Df & den Df & Pr(>F)\\\\\n",
       "  & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl> & <dbl>\\\\\n",
       "\\hline\n",
       "\t1 & 297 & NA & 0.4276241 &         NA &       NA & NA &   NA &        NA\\\\\n",
       "\t2 & 302 &  5 & 0.4279837 & 0.08566022 & 1.035382 & 25 & 1485 & 0.4151172\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A anova: 2 × 8\n",
       "\n",
       "| <!--/--> | Res.Df &lt;dbl&gt; | Df &lt;dbl&gt; | Gen.var. &lt;dbl&gt; | Pillai &lt;dbl&gt; | approx F &lt;dbl&gt; | num Df &lt;dbl&gt; | den Df &lt;dbl&gt; | Pr(&gt;F) &lt;dbl&gt; |\n",
       "|---|---|---|---|---|---|---|---|---|\n",
       "| 1 | 297 | NA | 0.4276241 |         NA |       NA | NA |   NA |        NA |\n",
       "| 2 | 302 |  5 | 0.4279837 | 0.08566022 | 1.035382 | 25 | 1485 | 0.4151172 |\n",
       "\n"
      ],
      "text/plain": [
       "  Res.Df Df Gen.var.  Pillai     approx F num Df den Df Pr(>F)   \n",
       "1 297    NA 0.4276241         NA       NA NA       NA          NA\n",
       "2 302     5 0.4279837 0.08566022 1.035382 25     1485   0.4151172"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# excluding the predictors: sd.pitch, speech_pace, nrc_disgust, nrc_anticipation\n",
    "model2 <- lm(cbind(Extr, Agr, Cons, Emot, Open) ~ gender + mean.pitch + mean.energy +\n",
    "  sd.energy + time.speaking + mean_words_sent +\n",
    "  var_words_sent + perc_quest + first_vs_second + \n",
    "  third_vs_other + perc_swear + perc_filler_words + nrc_anger + nrc_fear + nrc_joy + nrc_negative +\n",
    "  nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[\n",
    "  ,\n",
    "  -1\n",
    "])\n",
    "summary(model2)\n",
    "\n",
    "# adjust R² scores adjustment\n",
    "#  E 0.1873 --> 0.1821\n",
    "#  A 0.3204 --> 0.3225 \n",
    "#  C 0.1891 --> 0.1728 \n",
    "#  E 0.1265 --> 0.1309\n",
    "#  O 0.0379 --> 0.03978\n",
    "\n",
    "anova(full_model, model2)\n",
    "# no significant difference\n",
    "# however this is still the simplest model"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "00c18a49",
   "metadata": {
    "papermill": {
     "duration": 0.0242,
     "end_time": "2023-12-10T23:27:06.813580",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.789380",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.3 Predictive model: Individual models\n",
    "\n",
    "Excluding predictors had different effects on the different Big5 dimentions. That is why we decided to look at the models individually and exclude predictiors on the basis of the individuall models. First we wanted to look at every model and write down what predictors are not significant and make a new model on the basis of that. However, it would take a lot of work. So we looked at assigments form other groups in the hope that we could learn something from them. We saw that group 11 used the stepAIC() command. We regonized this command, because we also used it in the previous course \"Maschine Learning for Psychologists\". So we also decided to use it. It is a hierachical regression model that finds the combination of predictors that predict the most variance. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "eb8983bd",
   "metadata": {
    "papermill": {
     "duration": 0.021027,
     "end_time": "2023-12-10T23:27:06.855711",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.834684",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.3.1 Predictive model: Extroversion models\n",
    "\n",
    "Now we will find the best model for extroversion. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 19,
   "id": "23d9e75f",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:06.902480Z",
     "iopub.status.busy": "2023-12-10T23:27:06.900597Z",
     "iopub.status.idle": "2023-12-10T23:27:07.593534Z",
     "shell.execute_reply": "2023-12-10T23:27:07.591421Z"
    },
    "papermill": {
     "duration": 0.720037,
     "end_time": "2023-12-10T23:27:07.596884",
     "exception": false,
     "start_time": "2023-12-10T23:27:06.876847",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Extr ~ mean.pitch + mean.energy + sd.energy + time.speaking + \n",
       "    perc_quest + perc_swear + perc_filler_words + nrc_joy + nrc_sadness, \n",
       "    data = training_data[, -1])\n",
       "\n",
       "Coefficients:\n",
       "      (Intercept)         mean.pitch        mean.energy          sd.energy  \n",
       "         2.483375           0.003185           5.766593           0.167828  \n",
       "    time.speaking         perc_quest         perc_swear  perc_filler_words  \n",
       "         1.648783         668.608309          11.533835          -6.430452  \n",
       "          nrc_joy        nrc_sadness  \n",
       "         0.012492          -0.028209  \n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Extr ~ mean.pitch + mean.energy + sd.energy + time.speaking + \n",
       "    perc_quest + perc_swear + perc_filler_words + nrc_joy + nrc_sadness, \n",
       "    data = training_data[, -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.45073 -0.61100  0.06187  0.62524  1.85449 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        2.483e+00  3.459e-01   7.179 5.15e-12 ***\n",
       "mean.pitch         3.185e-03  8.633e-04   3.690 0.000265 ***\n",
       "mean.energy        5.767e+00  2.199e+00   2.622 0.009163 ** \n",
       "sd.energy          1.678e-01  8.171e-02   2.054 0.040814 *  \n",
       "time.speaking      1.649e+00  3.387e-01   4.868 1.80e-06 ***\n",
       "perc_quest         6.686e+02  1.660e+02   4.028 7.08e-05 ***\n",
       "perc_swear         1.153e+01  5.418e+00   2.129 0.034049 *  \n",
       "perc_filler_words -6.430e+00  1.984e+00  -3.241 0.001322 ** \n",
       "nrc_joy            1.249e-02  6.273e-03   1.991 0.047309 *  \n",
       "nrc_sadness       -2.821e-02  1.017e-02  -2.775 0.005859 ** \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.8672 on 313 degrees of freedom\n",
       "Multiple R-squared:  0.2188,\tAdjusted R-squared:  0.1964 \n",
       "F-statistic: 9.743 on 9 and 313 DF,  p-value: 3.77e-13\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "full_model_ex <- lm(formula = Extr ~ gender + mean.pitch + mean.energy + sd.energy + \n",
    "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
    "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
    "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
    "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "\n",
    "stepAIC(full_model_ex, direction = \"both\", trace = F) #finding the best fitting model\n",
    "\n",
    "# this is the model that we found\n",
    "\n",
    "model_ex <- lm(formula = Extr ~ mean.pitch + mean.energy + sd.energy + time.speaking + \n",
    "    perc_quest + perc_swear + perc_filler_words + nrc_joy + nrc_sadness, \n",
    "    data = training_data[, -1])\n",
    "\n",
    "summary(model_ex)\n",
    "\n",
    "# Adjusted R-squared:  \n",
    "# full model: 0.1873\n",
    "# adjusted model: 0.1821 \n",
    "# new model: 0.1964 \n",
    "\n",
    "# better R-squared"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "71bdee03",
   "metadata": {
    "papermill": {
     "duration": 0.023334,
     "end_time": "2023-12-10T23:27:07.642375",
     "exception": false,
     "start_time": "2023-12-10T23:27:07.619041",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.3.2 Predictive model: Agreeableness models\n",
    "\n",
    "Now we will find the best model for agreeableness"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 20,
   "id": "85b2374e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:07.689922Z",
     "iopub.status.busy": "2023-12-10T23:27:07.688070Z",
     "iopub.status.idle": "2023-12-10T23:27:07.905755Z",
     "shell.execute_reply": "2023-12-10T23:27:07.903702Z"
    },
    "papermill": {
     "duration": 0.244653,
     "end_time": "2023-12-10T23:27:07.908672",
     "exception": false,
     "start_time": "2023-12-10T23:27:07.664019",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Agr ~ gender + sd.energy + mean_words_sent + var_words_sent + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_fear + nrc_joy + nrc_negative + nrc_surprise + nrc_trust, \n",
       "    data = training_data[, -1])\n",
       "\n",
       "Coefficients:\n",
       "      (Intercept)         genderMale          sd.energy    mean_words_sent  \n",
       "        4.937e+00         -4.157e-01         -9.689e-02          2.322e-02  \n",
       "   var_words_sent     third_vs_other         perc_swear  perc_filler_words  \n",
       "       -3.396e-04         -5.071e-01         -2.344e+01          2.935e+00  \n",
       "        nrc_anger           nrc_fear            nrc_joy       nrc_negative  \n",
       "       -4.020e-02          2.201e-02          1.846e-02         -2.042e-02  \n",
       "     nrc_surprise          nrc_trust  \n",
       "        2.226e-02         -1.320e-02  \n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Agr ~ gender + sd.energy + mean_words_sent + var_words_sent + \n",
       "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
       "    nrc_fear + nrc_joy + nrc_negative + nrc_surprise + nrc_trust, \n",
       "    data = training_data[, -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.72522 -0.38768  0.08232  0.46187  1.91742 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.937e+00  1.834e-01  26.918  < 2e-16 ***\n",
       "genderMale        -4.157e-01  8.408e-02  -4.944 1.26e-06 ***\n",
       "sd.energy         -9.689e-02  6.568e-02  -1.475   0.1412    \n",
       "mean_words_sent    2.322e-02  9.422e-03   2.464   0.0143 *  \n",
       "var_words_sent    -3.396e-04  2.244e-04  -1.513   0.1313    \n",
       "third_vs_other    -5.071e-01  2.157e-01  -2.351   0.0194 *  \n",
       "perc_swear        -2.344e+01  4.717e+00  -4.969 1.12e-06 ***\n",
       "perc_filler_words  2.935e+00  1.669e+00   1.759   0.0796 .  \n",
       "nrc_anger         -4.020e-02  1.638e-02  -2.455   0.0147 *  \n",
       "nrc_fear           2.201e-02  1.217e-02   1.808   0.0716 .  \n",
       "nrc_joy            1.846e-02  9.216e-03   2.003   0.0460 *  \n",
       "nrc_negative      -2.042e-02  9.616e-03  -2.123   0.0345 *  \n",
       "nrc_surprise       2.226e-02  1.304e-02   1.707   0.0889 .  \n",
       "nrc_trust         -1.320e-02  7.942e-03  -1.662   0.0975 .  \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7293 on 309 degrees of freedom\n",
       "Multiple R-squared:  0.3571,\tAdjusted R-squared:  0.3301 \n",
       "F-statistic:  13.2 on 13 and 309 DF,  p-value: < 2.2e-16\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "full_model_ag <- lm(formula = Agr ~ gender + mean.pitch + mean.energy + sd.energy + \n",
    "    time.speaking + mean_words_sent + var_words_sent + perc_quest + \n",
    "    first_vs_second + third_vs_other + perc_swear + perc_filler_words + \n",
    "    nrc_anger + nrc_fear + nrc_joy + nrc_negative + nrc_positive + \n",
    "    nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "\n",
    "stepAIC(full_model_ag, direction = \"both\", trace = F) #finding the best fitting model\n",
    "\n",
    "# this is the model that we found\n",
    "model_ag <- lm(formula = Agr ~ gender + sd.energy + mean_words_sent + var_words_sent + \n",
    "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
    "    nrc_fear + nrc_joy + nrc_negative + nrc_surprise + nrc_trust, \n",
    "    data = training_data[, -1])\n",
    "\n",
    "summary(model_ag)\n",
    "\n",
    "# adjust R² scores adjustment\n",
    "#  full model: 0.3204 \n",
    "# adjusted model: 0.3225\n",
    "# individual model: 0.3301\n",
    "#better model"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a1c44851",
   "metadata": {
    "papermill": {
     "duration": 0.021583,
     "end_time": "2023-12-10T23:27:07.952146",
     "exception": false,
     "start_time": "2023-12-10T23:27:07.930563",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.3.3 Predictive model:  Conscientiousness model\n",
    "\n",
    "Now we will find the best model for conscientiousness."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 21,
   "id": "a7053b6a",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:08.001326Z",
     "iopub.status.busy": "2023-12-10T23:27:07.999234Z",
     "iopub.status.idle": "2023-12-10T23:27:08.358163Z",
     "shell.execute_reply": "2023-12-10T23:27:08.355974Z"
    },
    "papermill": {
     "duration": 0.387061,
     "end_time": "2023-12-10T23:27:08.361284",
     "exception": false,
     "start_time": "2023-12-10T23:27:07.974223",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Cons ~ sd.pitch + time.speaking + speech_pace + \n",
       "    mean_words_sent + var_words_sent + perc_quest + first_vs_second + \n",
       "    self_vs_we + nrc_anger + nrc_anticipation + nrc_disgust + \n",
       "    nrc_fear + nrc_positive, data = training_data[, -1])\n",
       "\n",
       "Coefficients:\n",
       "     (Intercept)          sd.pitch     time.speaking       speech_pace  \n",
       "       4.433e+00        -3.985e-01         1.193e+00         6.001e-05  \n",
       " mean_words_sent    var_words_sent        perc_quest   first_vs_second  \n",
       "       2.925e-02        -5.641e-04        -2.636e+02        -6.119e-01  \n",
       "      self_vs_we         nrc_anger  nrc_anticipation       nrc_disgust  \n",
       "      -5.416e-01        -4.281e-02        -1.338e-02        -2.514e-02  \n",
       "        nrc_fear      nrc_positive  \n",
       "       3.265e-02         1.513e-02  \n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Cons ~ sd.pitch + time.speaking + speech_pace + \n",
       "    mean_words_sent + var_words_sent + perc_quest + first_vs_second + \n",
       "    self_vs_we + nrc_anger + nrc_anticipation + nrc_disgust + \n",
       "    nrc_fear + nrc_positive, data = training_data[, -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.36956 -0.40909  0.00762  0.46377  1.84287 \n",
       "\n",
       "Coefficients:\n",
       "                   Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)       4.433e+00  4.273e-01  10.374  < 2e-16 ***\n",
       "sd.pitch         -3.985e-01  2.672e-01  -1.491 0.136868    \n",
       "time.speaking     1.193e+00  3.167e-01   3.768 0.000197 ***\n",
       "speech_pace       6.001e-05  3.891e-05   1.542 0.124066    \n",
       "mean_words_sent   2.925e-02  9.887e-03   2.958 0.003331 ** \n",
       "var_words_sent   -5.641e-04  2.164e-04  -2.607 0.009582 ** \n",
       "perc_quest       -2.636e+02  1.481e+02  -1.780 0.076049 .  \n",
       "first_vs_second  -6.119e-01  2.570e-01  -2.381 0.017853 *  \n",
       "self_vs_we       -5.416e-01  3.010e-01  -1.799 0.072928 .  \n",
       "nrc_anger        -4.281e-02  1.440e-02  -2.973 0.003178 ** \n",
       "nrc_anticipation -1.338e-02  7.301e-03  -1.832 0.067877 .  \n",
       "nrc_disgust      -2.514e-02  1.293e-02  -1.943 0.052887 .  \n",
       "nrc_fear          3.265e-02  1.107e-02   2.950 0.003418 ** \n",
       "nrc_positive      1.513e-02  4.188e-03   3.614 0.000352 ***\n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7038 on 309 degrees of freedom\n",
       "Multiple R-squared:  0.2374,\tAdjusted R-squared:  0.2053 \n",
       "F-statistic: 7.398 on 13 and 309 DF,  p-value: 1.155e-12\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "full_model_co <- lm(formula = Cons ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
    "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
    "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
    "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
    "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
    "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "stepAIC(full_model_co, direction = \"both\", trace = F) #finding the best fitting model\n",
    "\n",
    "# this is the model that we found\n",
    "model_co <- lm(formula = Cons ~ sd.pitch + time.speaking + speech_pace + \n",
    "    mean_words_sent + var_words_sent + perc_quest + first_vs_second + \n",
    "    self_vs_we + nrc_anger + nrc_anticipation + nrc_disgust + \n",
    "    nrc_fear + nrc_positive, data = training_data[, -1])\n",
    "\n",
    "summary(model_co)\n",
    "\n",
    "# adjust R² scores adjustment\n",
    "\n",
    "# full model: 0.1891 \n",
    "# adjusted model 0.1728 \n",
    "# idividuall model 0.2053\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "57f50eff",
   "metadata": {
    "papermill": {
     "duration": 0.022188,
     "end_time": "2023-12-10T23:27:08.406137",
     "exception": false,
     "start_time": "2023-12-10T23:27:08.383949",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.3.4 Predictive model: Emotional stability model\n",
    "\n",
    "Now we will find the best model for emotional stability model."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 22,
   "id": "052e97ac",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:08.456412Z",
     "iopub.status.busy": "2023-12-10T23:27:08.454469Z",
     "iopub.status.idle": "2023-12-10T23:27:08.983123Z",
     "shell.execute_reply": "2023-12-10T23:27:08.980931Z"
    },
    "papermill": {
     "duration": 0.557882,
     "end_time": "2023-12-10T23:27:08.986156",
     "exception": false,
     "start_time": "2023-12-10T23:27:08.428274",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Emot ~ gender + mean_words_sent + var_words_sent + \n",
       "    perc_swear + nrc_negative + nrc_positive, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Coefficients:\n",
       "    (Intercept)       genderMale  mean_words_sent   var_words_sent  \n",
       "       4.642473        -0.131621         0.021123        -0.000430  \n",
       "     perc_swear     nrc_negative     nrc_positive  \n",
       "     -17.169893        -0.019480         0.009464  \n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Emot ~ gender + mean_words_sent + var_words_sent + \n",
       "    perc_swear + nrc_negative + nrc_positive, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.18031 -0.42573  0.09963  0.47116  1.69462 \n",
       "\n",
       "Coefficients:\n",
       "                  Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)      4.642e+00  1.370e-01  33.887  < 2e-16 ***\n",
       "genderMale      -1.316e-01  8.133e-02  -1.618 0.106573    \n",
       "mean_words_sent  2.112e-02  9.178e-03   2.301 0.022020 *  \n",
       "var_words_sent  -4.300e-04  2.163e-04  -1.988 0.047678 *  \n",
       "perc_swear      -1.717e+01  4.500e+00  -3.815 0.000164 ***\n",
       "nrc_negative    -1.948e-02  4.444e-03  -4.384 1.59e-05 ***\n",
       "nrc_positive     9.464e-03  2.811e-03   3.366 0.000855 ***\n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.7136 on 316 degrees of freedom\n",
       "Multiple R-squared:  0.1605,\tAdjusted R-squared:  0.1445 \n",
       "F-statistic: 10.07 on 6 and 316 DF,  p-value: 3.488e-10\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "full_model_em <- lm(formula = Emot ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
    "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
    "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
    "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
    "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
    "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "stepAIC(full_model_em, direction = \"both\", trace = F) #finding the best fitting model\n",
    "\n",
    "# this is the model that we found\n",
    "model_em <- lm(formula = Emot ~ gender + mean_words_sent + var_words_sent + \n",
    "    perc_swear + nrc_negative + nrc_positive, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "summary(model_em)\n",
    "\n",
    "# adjust R² scores \n",
    "#  full model: 0.1265 \n",
    "# adjusted model: 0.1309\n",
    "#individual model: 0.1445 \n",
    "\n",
    "# better adjusted R²"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "407e5f1b",
   "metadata": {
    "papermill": {
     "duration": 0.022516,
     "end_time": "2023-12-10T23:27:09.031883",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.009367",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.3.5 Predictive model:  Openess model\n",
    "\n",
    "Now we will find the best model for openness model."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 23,
   "id": "9f66da2e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:09.081925Z",
     "iopub.status.busy": "2023-12-10T23:27:09.079933Z",
     "iopub.status.idle": "2023-12-10T23:27:09.594769Z",
     "shell.execute_reply": "2023-12-10T23:27:09.592537Z"
    },
    "papermill": {
     "duration": 0.543899,
     "end_time": "2023-12-10T23:27:09.598453",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.054554",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Open ~ gender + mean.pitch + time.speaking + perc_filler_words + \n",
       "    nrc_anticipation + nrc_joy + nrc_sadness, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Coefficients:\n",
       "      (Intercept)         genderMale         mean.pitch      time.speaking  \n",
       "          4.00546            0.14537            0.00140            0.57026  \n",
       "perc_filler_words   nrc_anticipation            nrc_joy        nrc_sadness  \n",
       "         -2.94158           -0.01419            0.02391           -0.02138  \n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:\n",
       "lm(formula = Open ~ gender + mean.pitch + time.speaking + perc_filler_words + \n",
       "    nrc_anticipation + nrc_joy + nrc_sadness, data = training_data[, \n",
       "    -1])\n",
       "\n",
       "Residuals:\n",
       "     Min       1Q   Median       3Q      Max \n",
       "-2.83014 -0.47270  0.00836  0.43119  1.62635 \n",
       "\n",
       "Coefficients:\n",
       "                    Estimate Std. Error t value Pr(>|t|)    \n",
       "(Intercept)        4.0054632  0.2772360  14.448  < 2e-16 ***\n",
       "genderMale         0.1453748  0.0851808   1.707  0.08887 .  \n",
       "mean.pitch         0.0013999  0.0007594   1.843  0.06620 .  \n",
       "time.speaking      0.5702592  0.2665723   2.139  0.03319 *  \n",
       "perc_filler_words -2.9415803  1.5584046  -1.888  0.06000 .  \n",
       "nrc_anticipation  -0.0141881  0.0072574  -1.955  0.05147 .  \n",
       "nrc_joy            0.0239121  0.0075007   3.188  0.00158 ** \n",
       "nrc_sadness       -0.0213839  0.0078609  -2.720  0.00689 ** \n",
       "---\n",
       "Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1\n",
       "\n",
       "Residual standard error: 0.6879 on 315 degrees of freedom\n",
       "Multiple R-squared:  0.07964,\tAdjusted R-squared:  0.05919 \n",
       "F-statistic: 3.894 on 7 and 315 DF,  p-value: 0.0004362\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "full_model_op <- lm(formula = Open ~ gender + mean.pitch + sd.pitch + mean.energy + \n",
    "    sd.energy + time.speaking + speech_pace + mean_words_sent + \n",
    "    var_words_sent + perc_quest + first_vs_second + self_vs_we + \n",
    "    third_vs_other + perc_swear + perc_filler_words + nrc_anger + \n",
    "    nrc_anticipation + nrc_disgust + nrc_fear + nrc_joy + nrc_negative + \n",
    "    nrc_positive + nrc_sadness + nrc_surprise + nrc_trust, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "stepAIC(full_model_op, direction = \"both\", trace = F) #finding the best fitting model\n",
    "\n",
    "# this is the model that we found:\n",
    "model_op <- lm(formula = Open ~ gender + mean.pitch + time.speaking + perc_filler_words + \n",
    "    nrc_anticipation + nrc_joy + nrc_sadness, data = training_data[, \n",
    "    -1])\n",
    "\n",
    "summary(model_op)\n",
    "\n",
    "# adjust R² scores:\n",
    "\n",
    "#  full model: 0.0379 \n",
    "# adjusted model: 0.03978\n",
    "# individual model: 0.05919\n",
    "\n",
    "# better model"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b2652ca3",
   "metadata": {
    "papermill": {
     "duration": 0.031235,
     "end_time": "2023-12-10T23:27:09.660199",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.628964",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "As we can see. The adjusted R² get´s better for all the dimentions. This means that the predictions get better. We use the adjusted R² because and not the R², because we also can controll for overfitting. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "1c1816d2",
   "metadata": {
    "papermill": {
     "duration": 0.023126,
     "end_time": "2023-12-10T23:27:09.709899",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.686773",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.4 Visualizing our model predictions on the training data\n",
    "Next, we visualize our model predictions by plotting the predicted personality scores of the training data to the \"true\" scores.\n",
    "\n",
    "To do that, we first predict the scores of the training data, join them with the true scores and transform the data frame in a way that is useful for gglot."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 24,
   "id": "38376f8d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:09.760792Z",
     "iopub.status.busy": "2023-12-10T23:27:09.758925Z",
     "iopub.status.idle": "2023-12-10T23:27:09.826427Z",
     "shell.execute_reply": "2023-12-10T23:27:09.824280Z"
    },
    "papermill": {
     "duration": 0.097101,
     "end_time": "2023-12-10T23:27:09.829969",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.732868",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# 1. Transform data in a way ggplot can digest perfectly.\n",
    "\n",
    "# predict on training data\n",
    "pred_train_ex <- predict(model_ex, new = training_data)\n",
    "pred_train_ag <- predict(model_ag, new = training_data)\n",
    "pred_train_co <- predict(model_co, new = training_data)\n",
    "pred_train_em <- predict(model_em, new = training_data)\n",
    "pred_train_op <- predict(model_op, new = training_data)\n",
    "\n",
    "#combining predictions\n",
    "trainset_pred = cbind(\n",
    "    Extr = pred_train_ex,\n",
    "    Agr = pred_train_ag,\n",
    "    Cons = pred_train_co,\n",
    "    Emot = pred_train_em,\n",
    "    Open = pred_train_op\n",
    "    ) %>%\n",
    "    as.data.frame() %>%\n",
    "    #add vlogId from test_data\n",
    "    cbind(training_data$vlogId,.) %>%\n",
    "    rename(vlogId = 1) %>%\n",
    "    pivot_longer(-vlogId, names_to = \"trait\", values_to = \"pred_score\")\n",
    "\n",
    "# join real training data scores\n",
    "trainset_df <- trainset_pred %>%\n",
    "    left_join(\n",
    "        vlogger_df %>% \n",
    "            select(-gender) %>%\n",
    "            pivot_longer(-vlogId, names_to = \"trait\", values_to = \"true_score\"),\n",
    "        by = c(\"vlogId\", \"trait\")\n",
    "    )"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 25,
   "id": "978acef6",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:09.880810Z",
     "iopub.status.busy": "2023-12-10T23:27:09.878881Z",
     "iopub.status.idle": "2023-12-10T23:27:11.802057Z",
     "shell.execute_reply": "2023-12-10T23:27:11.798722Z"
    },
    "papermill": {
     "duration": 1.952733,
     "end_time": "2023-12-10T23:27:11.805906",
     "exception": false,
     "start_time": "2023-12-10T23:27:09.853173",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "image/png": "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"
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    },
    {
     "data": {
      "image/png": "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"
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    },
    {
     "data": {
      "image/png": "iVBORw0KGgoAAAANSUhEUgAAA0gAAANICAIAAAByhViMAAAABmJLR0QA/wD/AP+gvaeTAAAg\nAElEQVR4nOzdd3xb52Hv/+dgg9iDAPcASFGkOEQNSqSoaUuyZcWSHduJE4/0Jumv6f3dNElH\nbprh9iZN2iR1f0kbN71p8ktu24yXo9iWLdmSrC1RixL3pjhAcGGQIPY4OOf+cRKEoSSaIgmS\nAL7vv+wj6JwHMMfHzznnORTLsgQAAAAAEh9vtQcAAAAAAMsDYQcAAACQJBB2AAAAAEkCYQcA\nAACQJBB2AAAAAEkCYQcAAACQJBB2AAAAAEkCYQcAAACQJJI27Nio583X/tezB7bnZuilQpFK\na6iuP/g/X/1PR4RZ7aEBAAAAxAWVlE+e8I2ee6r+6JkhDyFErNBlaKWuyfGZYJQQoih45L3G\nd+p0ktUeIwAAAMAyS8IZOzrQc7D8iTNDnvw9/+3kjb6g2zE0NOLyeVrP/uKpCq1n6Oyhmj8N\nJWHNAgAAQKpLwhm7Hz+e96n3RnIe+9u+E1+T/GG4RkMjjxiLL86EXjo/+rM9Was0QAAAAIC4\nSLYZu+DU2585ZeWLMt/+9Zck97w5vjj3n/6sjBDy3p+fWewRGF+QXtIQAQAAAOIj2cKu78df\nj7Bs9iM/2CgT3vcF5X/14zfffPPH3yidtY25+J/fenJXZbpaLpKpCsvr/vSVH42For/f5892\nURT1yb7pxv/4cnmOWi4VCsSywsqdX/m3uXU41X7is88/VpSpEwtFKl3OzsN/9MsbE8v/JgEA\nAADuJ9lOxf5zie6zvVOH3h858UjOAv/K91/a+Gf/0UJRlKGwvMQobmtsmo5EVUVPNrQcK0sT\nEEL6frZr3ScuP/LdT5z7y5+lZZi3b9kQGm25cmeIEHL4e21vf7ac24/jzj8Vb/sLF81oTRvK\ncjVTw22dQzM8vvz/a7P8j1JNfN4uAAAAwO8l24zdlekgIaS2WLXA1w/95sU/+48WsWrrmy32\nibutFxtuTU51fWFP5kz/8UMf+fnsV579i5/Wff5nDmvf+8ffvHx78NL3nySEnP1ffx17wT88\n/TcumnnxRw3Ou+2XL1zuGJx6+8vbmKj3Gy/8ZvneHwAAAMADJduM3ValuNET/vcJ3yeNaQt5\n/aezFf8+5v381YlX64yxjXSgO19TPh4RNrndVTIhN2OXpn/aZTsmpH73IjakE6fN8DLo4Ci3\n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\neDy5XC6RSKqqqh605tz8aJp+6623rl27JpPJuGvsJiYmPB5POBzm7pjhnk+fn5//6KOPPuhk\n9AIFg8G33367tbW1qKgoOzubz+cHg8Hr16/z+fznn39eJpMdOnSopqbG4XBw05CLe0eQmhB2\nAADzSUtL4xYPm73CBcMwwWAwIyODW01DIBDMDq97V82Yjc/nT05OTk5OlpSUxBZUC4VC3E0M\nhBCdTnfkyJGDBw9yCxQv5KxfYWFha2vr7OcfcLcFbNu2jVuDY87rRSJRKBRSqVRcntI0zcUr\ntwRuWlqayWTizjJzd4REIhGPx8Mtzjc9Pf0P//APFy9ejEQiAoGARCK6Y8coj4cQEtm8+WIw\nWGk2cx3M5/MzMjJmZma4515cvHjx2rVrPp+Px+PNzMy0t7f39PQ899xzer3+3XffvXr1qsvl\n4tbPa25u7uzsfO655+Z5tn12drbL5erv7y8sLNTr9dxcms/n27Jly5y16Baor6+vtbU1IyMj\ntnSIXq/v7OyUSCTr1q1zOBzcKjDbt29f+g2wd+/eHRgYMJvNCoXC4/EQQrRabSQS6enpGR0d\n5b7S9Ho9t6YJwENB2AEkJO6ZmKs9ioQUDofv3LkzPDzscrmMRuP69etLSkrm+TApiqqurh4Y\nGLh7925+fj73/Kj+/v6srKyNGzd6vd7h4eHZ/zlomg4Gg7Mr8F7c61mWDYVCkUhEKBSyLDsn\nByUSycIv5Nq0aVNXV1dXV5fBYJDL5X6/f2JiorCwsKam5urVq52dnXNe7/P5MjMz169f39TU\n5PP5uEvuCCHc+ceCggKNRlNXVzc+Pj4yMuLz+fh8fn5+fmFhYV5e3ttvv33x4kWGYWQyWTQY\nrB8cTPd4CCGh6uqxmhre1atzZjflcrnX67127dr169clEonZbPZ6vXK5PBAIdHR0XLx4saKi\noqGhgXsuLfdX/H5/R0fHhQsXnnvuuQe95fHxcZVKtX79+pmZGY/Hw52yTE9Pp2maW5d4gR/d\n7B263e7CwsLZGzMzM91u9759+3Jycng83gfe7LxALpfL5/PNWetOpVINDQ25XK75v3i8Xm9L\nS4vD4SCEGAyGqqoq7lG2AByEHUAimZiYuHXr1vDwcDQa5RbBn7PeFczP7Xb/+te/bmtr465s\na2pqamxsrK2tffzxx+f5nb1lyxav19vQ0NDV1RWNRoVCYW5u7t69e00mUygUGhwc5G6YkEgk\nPp9veHi4oKBgngvsotGo0WhUqVTt7e2RSIQrPG6pkUXP0KSnpz/33HMXLlzo6+tzOBwSiWT7\n9u27d+/OyckpKSm5c+fOyMhITk4OV582m41l2fLy8nA4HI1GaZqONSVXeDk5OZmZmTKZ7OjR\no1NTU9wCxXq9fmhoSKlUxk6Yuuz2Q5OT6YEAIaRTqRw3GNYJhdFodM7/dYRCIYVC4XQ6Z2Zm\nYo81I4RIpVKdTtff3y8QCKampmZ/YmlpaXq9vr+/n5uzvO9bdjqdMpmstLS0s7NzZmZGJBJl\nZmYajUa/3z81NbWIm0a5K/O4kUciET6fz01hch/R8j6zi9t5NBqdvVvu4WDzP19kYGDgnXfe\n6e/v50YrEAhu37795JNP5uXlLePwIKEh7AASRmdn5/Hjxy0WS1paGkVR3d3dHR0dBw8erKmp\nWe2hJYwrV67cvn07tkYG91yHq1evFhQUbNiw4UF/i8fj7du3r7S01GKx+Hw+pVJZVFTE7aG0\ntPTIkSOXLl2yWq3cjQiVlZX79u2b5zmhAoFAJpOFQiHulzpXEnw+nzs3uui3lpWV9dGPfpRb\n3lahUHDrDxNCKioqrFbr9evXm5ubRSJRJBJRKBS1tbXbtm37xS9+wePxRCIR9+wyLjEpihoa\nGioqKtLr9cPDwyaTyWg0siw7MTHBMExlZeWlS5d8Ph9F0086nTmhECGkTSZ7TyzOmpw8cPCg\nVCqdnJw0Go3c+/L7/W63e/Pmzf+XvTeNbuswr0UPpoNzMM8DB5AEZ4KTSFGcNNCiZtlqZDtO\nPEix0zZ5dzld6euwVvv62nVf+1bfur3tbdOmuR1yb7yynp3BsR1ZtmRL1EBRHCVSJAgQAAmA\nIDGPxDwD5/34XnBZ0qJlSnIs5+xf4uHBmamz8X3f3ptOp2+nLBiGZTIZUA9sKZriOJ5Op3fI\npaVSqT6fz+v1go0LQRDRaNTlcpWEDp8VAoGATqebzWa3251IJCgUCrjEPY4RN6VSKRKJPB5P\nRUVFaeGnhoOlUqnLly8bjcbGxkYoSSaTyaWlJRRFX3311e0NdxK/mSCJHQkSTwZSqdS1a9cc\nDkdraysQgmKxaDQab9y4UVdXt/NkPQlAJpPR6/UcDqfkkQG5Dvfu3TObzTsQO4BSqfzEl25n\nZ2ddXZ3L5YrFYgKBoKKi4lM9YwuFQjKZVKlUMJIPJStgTg9yItlsNhaLcbncLe9yEFduKfvR\naLTTp0/X19ebzWa/3y8Siaqqqtra2qhUqtlsZjAYCoUinU6DpwmTyYzFYh6PRyaTDQ8Pj42N\nabVaoE0CgWD//v39/f1/+7d/m0+lnonFVNksgiA6Ducqh5OMx6PR6DPPPLOysjI9PQ1Fvkwm\nk0qlampqXn755UAgsL2Yl0ql4HZApXDLr3Ac36GjSqFQ3G43jUYD1z0EQRKJxMrKikAg2F3h\ns7GxMZ1O3759m81m83i8YrE4Pz9PpVJfeeWVUhbFo4JKperq6hodHV1ZWcEwjEKhrK2toSja\n39+/mURCQbdU1VtdXbXZbGq1unRZWCxWVVWV1WpdW1urr69/tAdJ4gkFSexIkHgy4HA4nE6n\nSqUq/S9PpVLVarXVarXZbCSxexAkk8l0Or19IAlFUQho2h0IgnA4HOvr6yAvoNFoO6fEgi9a\ndXV1LpdzOBxgUMxmsx+kqx4Oh8fHx/V6fSqVwjCspaUFguF3/hSFQmlsbNxitIsgCLiZiESi\nQqEAElooHOZyuXw+PzQ0VFdXt7y8DJqGysrKpqYmCoXCQJCXMpmqQgFBED2XOyaRUDKZYrHI\nYDBEItFf/MVfvPXWW6CWEAqFtbW1L774Ynd399LSklAotNvtpaZhIpHY2Njo7u5uaWmZnZ11\nOByl2bJUKhUIBIaGhnYoYVKpVJhNjMfjOI4Xi8VYLMbhcOh0OljNferF3IJgMMhkMqVSaaFQ\ngIqdSCQqFotwNR5tK5ZCoZw8eVIkEk1PT7tcLphr7O/vL6XGLS8vz8zMuFwuKpVaWVnZ29tb\nXV0di8WACm/eFIfDcblc0Wj0ER4eiScaJLEjQeLJQDKZhE7f5oXQyUomk7+uo3qygGEYiqKR\nSGTLcuhO7m6bkCExOzsbCoWgoSmXywcGBoaHh+83tAfVqebmZgzDgsFgIpHgcDgSiSQWi5UM\n2Px+v81mg7IcqD4RBAmHwz/5yU8gC4vNZofD4cuXL6+trb300ku7Y/ZKpRJMVcCWDy5FNput\nrKwERlVRUbG5V4ggSC6Z7FpYwAsFBEHuMZlXUJSIRgmCYLPZIFxQKBS///u/7/P5wOJOJpNB\n/bKpqWlgYGBiYgLKYDQajSCItra2Q4cOCYXCvr4++BWXy4VjaGlpGRoa2vnKq9VqOp3ucrlC\noRCNRhMIBPX19UKhMBKJQAMXaB+TyXwQnme324vF4unTp30+H+hFQDUcDAa39EwfCZhM5sGD\nB/fu3bu8vMxkMtVqdanQOz4+fuXKlUAgwOfzCYKwWq3Ly8tPP/00iqJ0Oj2Xy20uCYM2mezD\nkiiBJHYkSDwZYLFYYC22+f/0dDrNZDJJTdwDAsfx+vr6q1evKhSKkuAU4gd2rrHtgJmZmbGx\nMT6fD6kPxWLRZrPdvHlTqVS2trZ+4kfodLpcLofxtdIoHgyxKZVKgiAmJibGxsZcLhdU0crK\nyg4ePDgwMHD37l29Xt/Q0FC64+l0emlpaWZmZucEs/vh6NGjd+/eDYVCdDodaGg+n0dR9ODB\ng5/4UEG2BO5wIAhikUrvCgR4Os1gMHg8Hqh54KqCafMWTxAqlXrq1Kmamhq9Xg+a4pqamp6e\nHtjR6dOnq6urtVotOC3X1tbu27fvftN1ABRFmUwm9MGTySSdTufxeJFIpFAowCghKGMgtK26\nunpwcHBncpZOpwmCwDBssxAhFouBQ+FnuKyfBSwWq6ysjMFglP6uA4HArVu34vF4e3s79KaL\nxeLS0tKNGzfOnj0rkUgcDkdtbW1pCw6HQyKRPHLeSeLJBUnsSJB4MlBZWVleXm40GqHZhCBI\nsVi0Wq1lZWW7JiW/gdi/f7/T6TSZTDiOoygai8XodHpvb29bW9sutkYQxOLiIkEQJX4G/fH5\n+XmDwXA/YocgSHt7u9FotFgs1dXVNBotn8+vrq6KxWKNRqPX6z/66KNUKtXY2MhgMHK5nNVq\nvXz5Mp/PX1lZYTAYwIRgIg3DMBaLtby8fPz48V0oBr7yla+MjY2NjIzEYjHwsWMymV1dXa+9\n9hqsYLfbl5eXI5EIh8NRSiRLf/zH9uvXEQRZLyublskKsRiDwaBQKPl8nsvldnd372wpTKVS\nNRqNRqMJBAJbxuCoVGpzczOIZ9lstlKp3JnVIQhSXl7O4/H8fr9MJoOhyWKx6PF42tvbxWLx\nBx98cPv27Vwux+fzIdvXarU+//zzOwyicTgcGo0G7jOlhdDn3fm8Hi3W19e9Xq9arS7dUCqV\nWlVV5fF4MpnMwMDAyMiITqcTi8UEQQSDQT6ff+DAAdLBmEQJJLEjQeLJAIZhR44cSSaTOp0O\nVLHxeLysrOypp54iB+weHDKZ7Ny5c1NTU8vLy8lksqqqqqOjo6ura3dBAul0GubPtixnsVhg\nNXw/dHR0bGxsjI+P63Q6giCoVGpZWdmBAwc0Gs1PfvKTYDBYW1vrdDqhSapUKq1W68LCQiqV\notFoVqvV6/XCPJlcLqdSqSB92MUQWLFYrKqqqq2thXwzGo2GomhdXR2CIARB3Lx5c2xszOPx\nUCgUJJeruHqVYbMhCKJ+6aU7uVx0bg46qsViMZFISCSS1tbWXdu8OZ3OkZGR5eXlRCLBYDCg\nnd3X17fDBpuamvbs2TM1NRUOh/l8fi6XCwQCFRUVQ0NDFovlzp070PJeX19nMplcLtdms924\ncUOtVkMWHJi24DheUVHR3d3NZrNra2uVSqXZbG5oaIDGNNgB9vf37+CT/MiRTqe3NFsRBGEy\nmdlsNpVKDQ0NCQSCDz74wOl0UqnUioqKZ555ZoevECR+A0ESOxIknhg0NzeLRKI7d+6sr6/n\n83kQ1n3p/auy2ez8/LzT6YzH41KptKWl5SFPWSAQnDhx4vjx45Cp8DCbYjAYnyi8yGazO/fH\nwT+lpqZmdnbW7XaXlZXt27evsrKyWCy63e5IJHL79u1IJAJVNAiNBT/eS5cuUSgU6DZubGxA\ncNnzzz+/u9H++fn5QCDwwgsvpNPpVCqFoiiHw9Hr9dPT0wRBXL9+PZPJtLe3U/L55D//c8Fm\nQxBE8vTT5b/3e+x/+zeNRhMKheLxOIZhIpGIyWTuWoASiUTeeecdg8FQWVmpVCpzuZzdbr94\n8SKNRuvt7UUQpFAoOByOjY0NoLkw/0en07/yla+UlZXdvXs3FouBdd+BAwdqampGRkYMBkM+\nn49EInQ6HS4jm80GXbDFYrl+/brL5cIwLJ/PUyiUxcXF5557TqFQHDly5OrVq3fv3gW/aBaL\n1draeuzYsUflS/wg4HA4TCYzmUxuzs9IJBIYhnE4nEgksrKyAl3jQqEAsb/V1dWfWuAk8ZsD\nktiRIPEkQS6XP/3008hvTPJEOBx+9913dToduL5ls9np6emhoaFDhw495Jahj/mQG6HT6XV1\ndWazeXOWVzweJwhiS4DBdty7d+/HP/6x0WhMJBJsNnt6evr8+fMajcbn81mtVhzHMQwDRhIO\nh91ud0VFhUAgCIfDPB6vrKwMLEg8Hk8oFNo5wQxBEIIgDAaD2Wx2Op0ymay2tratrY1Go9nt\ndgaDEQ6HfT5fPB6H8DSBQOByubRabSAQ6OzsRHK55D//c8FoRBAk0daGHjliW1sDHQ/UGhEE\nodFoXC7XarUmk8ldTHzqdDqz2QxqEgRBUBRtamrS6/UzMzPd3d1+v39kZMRoNMIgnVQqHRwc\n7O/vp1KpGIYdPHiwoaFhfX0dVCawBafT6XA4BAJBZWUl/JlkMhm73U6lUtfW1m7cuBEOhzs6\nOuDgoQrO4/FeeeUVjUZjsVjMZnMgEEBRlM/n79mzRy6Xf9YzehhUV1dXVFRYrdampiYoJGez\n2fX1dY1GU1ZW9s4770xNTSmVyj179hAEEQgEbt68WSgUXnjhhc+TfZL4IoMkdiRIPJH4TWB1\nCIKMjo7evXu3urq6NERlsVhu3rypUqk+lTl9Pujr61tdXTUYDEKhEJInYOy95FvxiVhcXPzL\nv/xLq9XK4/FwHI/FYh9//PHq6upf//Vf5/N5n88HMVww7wX/BkeS8vLyQqEAHAW0qFDn22Ff\n+Xz+vffeu3Dhgs1mg+8DCoXi+PHjr7zySqFQWF9fN5vNIALN5/M4jrNYrD179gSDQQzDNrM6\nxoEDxFNPRWOxVDq9trYGBnhQ9AqFQqurqywWK5PJ7ILY+Xy+fD6/hWdLJJJgMLi+vn7p0iW9\nXl9RUaFQKHK5nNPphGJeX1/fxsbGrVu3tFptPB4HScr+/fv37NkTiURSqdTmMTUQxsZisdXV\nVbfb3dzcHAqFStJXhUJhtVrdbveNGzempqYUCkVzc3M+n/d6vR9++CGVSu3r6/usJ7Vr8Hi8\no0ePwlmjKAqVObVafezYMY/HYzKZysvLS2m2oFDR6/UOh+NLX7wn8YAgiR0JEiS+oIjH40tL\nSwKBoOQnTKVSa2trFxYWIPr913t4ALlc/tJLL42Nja2srGQyGZFIdOjQoYGBgZ3H7d9+++2V\nlZWmpqaSf008HjeZTG+//XYqlUqn06BUpVAoqVQqFAqxWKxUKhWNRpuamrhcbiAQgNqYWCxO\nJpMwIXe/buzMzMyPfvQj8M5gMplgnvfWW28BT1pbW5PL5aW0sVgsZrFY6uvra2tr86nUZlaH\nv/yyd20NZ7GSyWQ4HG5ra4M9wkicXq8PBoPA6sxms8lk8vv9PB6vsrKys7NzdyOMCIKYTKaV\nlZXGxkbYMpPJbGxsXFpamp6ebmlpeeedd+bm5iQSiUwmy+VyFovF7/cXi0WhUMhisQKBgEwm\ng2m5dDqdzWZFIlEmk0kkEnNzcx6PJ51OU6lUDocD8gudTre4uKhUKkvCDolEYjAYJicnOzo6\ndg6f9fl8CwsLHo8Hks26uroeRm/R1tYml8vv3bvndrth/rK7u1soFM7MzESj0S1paSKRaGVl\nJRgMksSOBIAkdiRIkPiCIh6Pp1KpzZNGCIJAEPsXyo5VJpM999xz6XQaDIo/1VGsWCwuLi6y\nWKzNXIHD4TAYDJ1OB7Pzm38F2li3293V1bW+vl5bW7t5lt9gMHC53B1m7K5cueJwOBoaGkrb\nFAgERqPxww8/bG9vR1EUSA+Kovl8PpFIwGplUqn80qWC3Y78itXl8vmNjY09e/ZAcc7r9cKB\n0el0giCgsphKpW7evDk+Pu73+2G4jclk6nS6559/fgenQKlUSqPRQClSWhgMBmtqasAteUsV\nUCKRhEKh6enppaWlmpqakomxSCTS6/UTExONjY1Q2gSDX4IgaDSaTCarr69HUXR1dRVWhsSL\nSCSi1+vVanUkEolGo1u+MCgUCr/f7/V6d9Cez8/PX7582W63l+b5FhYWzp49+zAWJDKZ7Pjx\n41sWQvDals47NMR/Q0r4JB4EJLEjQYLEFxTQPstms1uWF4vFncsnvxZgGPaAQ3vZbBYy5rcs\np9PpkKxKEER5eXmxWAQfO8ibCofD9fX1Wq02GAyWEq5CoVChUGhpadlhd1arlU6nb75iKIqy\n2Wy73d7S0tLY2JjNZoPBYDabpdPpfD6/oqKCh+OOv/orzG5HECTV0ZE6csRvt4dCobq6usHB\nQRiw83g8JatnDMNkMll5ebnZbB4dHXW5XCCVZTAYbDZ7cnJSLpefOnXqfkfY2tp69+5do9Go\nUqkwDCMIwuVyMZnMffv2faK4GMiN1+tNp9NboilkMlkgEOju7m5ubk4mkwRBxGIxFEW5XG4k\nEqmvr8dxPJPJcDgcqKjRaDShUOjxeJLJJJQVtzAkkP2WjKO3IxQKXblyxe12l7L+IL+VzWZ/\n4xvf2H6XHwZSqVQgEAQCgc3Rdj6fTyAQfJ66XRJfcJDEjgQJEl9QCIVClUo1OTkpk8lKvTyv\n1wsNvk/9eCqV8nq9qVQKhqi+OKPlGIbJ5XK73b5ZAUMQBKTHLi8v4zgejUZxHKfRaIVCAVJT\nURTt7u5eX1+fm5tzOp1sNhu4yN69e3t6emAji4uL09PTPp9PKpXu2bOnu7v7foUcqPqwWCwu\nlyuVSi0WSyAQEAgEKpWqmMkw33rLs7KCIIjo1Cl3f/9GOMzhcIaGhg4ePKhQKCgUSjqd5vF4\nPB4PwrsYDEY8Hs9ms06nEySlhUIBw7BYLOb1eul0+vT09OHDh4G0BYPB1dXVTCYjlUqhuikQ\nCJ555pkf/ehH169fj8fjDAajqqrqueee6+3tnZqagoiwLcW8ysrKLaVcANTnIIPr9u3b6XS6\nrKwsl8tFo1G1Wn348GGz2SwWiwuFgtPpBHlKOp1WKpUymQwyyrboP8DOZgeXOIvF4nQ66+vr\nS0VTFotVXl6+urrqcrke5EF9cKhUqra2tlu3bmWzWegX+/3+eDw+PDxcclIkQYIkdiRIkPji\nYmhoyOfz6fV6Ho+Homg0GoVJ9ubm5p0/uLCwAOEN0MhrbGw8fPjwliyEXyOGhob0er3Vaq2s\nrGQwGCB75PF4Bw8ejMfjdrsdbHUzmQyNRhOLxZFIpKysDMfxF154ob6+HibYpFJpfX19V1cX\niqKFQuHf//3ff/nLX3o8HugGSqXS48ePf/e734WpRGCHsPdsNptMJjs7OxsbGy9cuHDt2rVQ\nKJTP56lUqoTP/61QCNnYQBCk6dVXKc89515YgE/lcjmj0bi8vGwwGKLRaC6XAxYFhTEmk0kQ\nBBQUKyoqSu4bMPoG4t94PD46OqrX62HgDxI1NBpNPp+fnZ0FX0agRwRBgIZXo9HU1tYaDIby\n8nIg94FAgEaj9fT0UCgUSLaFwUEYSQyHwyKRSCwWnzp1qry8HHI1GAxGT0/PwMCAUqm0WCwq\nlUoqlS4vL4P0tb6+Xi6XEwRRW1u7urpqMpnq6uo4HA5BED6fLxwOHzlyZAerSNC4bLGd43A4\n4XA4Fos92seGQqGcPn2azWbPzs66XC4EQQQCARDuR7sjEk80SGJHggSJLy5UKtW5c+fGx8ct\nFksul5PL5d3d3V1dXTvbti0uLr733nuhUKi8vBy0kGNjY6FQ6Pz5818Qu6/nn3/eZrNdu3bN\nZDJBUU0kEh0/fvzMmTOBQGBpaYnBYJSXl0PPMR6Pc7ncvr4+CoXCYDD27du3b9++LRv86KOP\n3nrrrVQqVVdXVygUYrGY2+1+6623lErlsWPHpqengThiGJbL5SKRCFCfQqGg1WphHo7BYBDZ\n7NDqqqRYRBCk+bXXnL2985cuCQQCoVAYjUbfeOMNyA1bXV3d2NigUChsNhvIFkEQcJ1zuVwm\nk9l8kcHqLxKJxGKxy5cvLy4uSqVSsVjMYDD0er3P50MQpFgszs7OisXiUk85l8vpdLqbN2+e\nO3fuxIkTDofj2rVr0NtVKpXPPvtsf39/JBJRqVRjY2NQIKTRaFQqlc/nHzlyBIp53d3d3d3d\nyWQSIlZhy1KplEql3rt3b319HVSxoVAoGAz29vZWV1c/88wzDAbDbDan02kKhSIQCA4cOHDk\nyJEdbiWTyaRSqVvEK5lMBkXRh/fT2Q4Wi3Xq1Kmenp5AIEChUOBiPvK9kHiiQRI7EiSeMCST\nyWAwWCgUJBLJ55l09OuCXC5/9tln8/l8Op1+kPMtFouTk5OBQKCtrQ04E5vN5vF4y8vLCwsL\nBw4cePyH/B9gs9ksFovNZqurq6urqwNJI47jf/qnf3rgwIG7d+96PJ7y8vJ9+/b19fXRaLQT\nJ06srKzMzc2V8knpdHpPT8/Ro0d32Mv169eDwWBra6vH49nY2MhmswRB+P3+H/7whz//+c+/\n+c1v/vKXv1xdXY3FYjQaraqq6tixY0ePHv2DP/iDRCIB9SpKPn8mGKwsFhEEcVZW7vvGN3Tv\nvFNXV8dmsxOJxNraWiaTgWxiDocDrI7D4SiVSiaTieO42Wz2eDytra0oisbj8dKdyufz2WyW\nx+MZjUaj0VhfX89ms2EFsVis1WrHx8fLysqi0ejm/FMGgyGVStfW1nw+38zMTDKZrK+vh3HD\nTCZjtVpXVlYaGhq4XO7GxgbU8IrFIo1Ga2trq6qqgo1Eo1GDwbCxscFkMhUKRWNjI5VKramp\nMRgMi4uLcCKFQsFqtTqdzra2NjabrVarX3vtNaPRGAwGURRVKBT19fU76xKg/re+vq5Wq2FJ\nsVi02+2NjY2Prz0qlUpLjickSGwBSexIkHhikM/nZ2ZmJicnwZOWz+fv27evv7//cRQGvmig\n0+kPyGKj0ajP55NIJJvfxywWq1AoeDyex3aAn4BCoXDlypXp6WmPxxOPx+fm5pRK5f79+w8d\nOkShUOh0+tDQ0NDQ0JZw0urq6t/5nd8BS95oNMrj8Zqbm48cObJzIvDa2hqkU3i9XgzDeDwe\nTMJZrdZ33333+eef39jYQFEUBuk6OzuffvppDMMMBgOCIHK5nFYsDphM8nQaQZBFNnuGxWo0\nGNLp9Ozs7MrKSjQahSNRKpXBYBBBEDqdzmazs9kslUrlcrlgaN1WAAAgAElEQVQQ3sVgMJqa\nmqampmKxWCwWYzKZEI3A4/EaGhrC4XAul9s8GAcFJ6/XC0WvLWeEYVg6nV5cXNRqtRUVFaW6\nFGiKb926RRCE3W7v6ekB0QkcktvtHh8fr6+vNxgMV65csVqt+XweQRCBQNDe3v7000/fvn07\nGo1CFBtc+fLy8lgsptPpgG7iOL5nz577XWdwhKbT6aWA2oqKioGBgRs3bmi1WqFQWCgUwuFw\nWVnZ0NDQQ/5hZrPZjY0NiB7ZtV8Mid9AkMSOBIknBjdv3vz4448LhYJcLqdQKMFg8MKFC+Fw\n+Ctf+crnb3aQSqX8fj94g22eQCoWiyaTyel0hsNhlUoFye6f54EVi8Visbj9gkASV+lHgiCy\n2eyW0ahHi9nZ2Rs3bjAYjLa2tkgkIhAIbDbbyMiIVCrVaDTJZPLOnTswryYQCFpaWvbu3QtU\noLm5uaamxuVyAZ0qKyv7VIqAomgmk8lmsxiGlWbpaDQak8k0Go0/+MEPvF6vVCqtrq5Op9Nm\ns/mnP/3piy++CMzs/2d10SiCIFaZ7CaTySwWA4HA9PR0KSUskUiAYrelpUUmk7HZ7HQ6nU6n\nI5EIlUoFnxeVSgUzfx6PJ5fLpVIpBoMBIRm9vb2pVIpKpQYCAY/H4/f7ocOLomixWGSxWNBO\nDYfD8Ck+nw8N6HA4HI/H6+vrS2dKpVLlcrnb7dbpdKFQqLOzc/O9LhaL6+vry8vLH3744fr6\nek1NDUEQdDo9Go2OjY2x2Wyj0ZhOpzs6OlKpFJw+juOQvbG0tLS9x11COBy+efPmwsICVD1F\nIlF/f//AwACdTh8eHpbL5TMzM36/n0qltrW19ff370zEd0Yul5udnZ2cnAyHwxQKRSwWDw4O\ndnZ2fnEEQCS+yCCJHQkSTwZCodDMzAyNRiu95AQCgdPpvHfvXldXV6n99DkAJqLAq6xQKHA4\nnM7OzoMHD/J4vHg8fvHiRa1WGw6Hs9ksh8Opqak5fvz4p2odHiF4PJ5QKLRYLJstIXK5HEEQ\n0L0Kh8NTU1PLy8upVEooFHZ0dHR1dUFFxOVyQb8SjnyLE+xnhVarLQ29IQhCo9FAx6DX61Uq\n1c9+9jOtVkuj0XAcd7lcS0tLFovlq1/9KkgyMQwrtfYeBK2trXfu3MnlciiKJhIJOp1Op9Mz\nmUxdXZ3NZnM4HP39/aWSZyaTMRgMU1NTFRUVFqOx32iUx2IIglhlstmqqpTNpiwr83g8LpdL\nJpNxudx0Og11r0gk4na729rapFIpQRA2mw1KSqBsaGxshASwiYmJUCgkkUgg01aj0UDTeX19\n3Wq1glCDTqezWCwGg3Ho0KH29vapqakPP/wwn88DscMwjMlknjt3jkKhbOfodDo9lUolk8nt\nv2UymbFYbGlpaXV1FUXRycnJdDoN8RIsFmtxcTGVSiEIAtGxpfIhg8EA9fH9Lm8ul7tw4cLM\nzIxEIqmoqIDq7/vvv5/P5w8fPkylUtvb29vb26Fw+KlGhp+Kq1evXr9+HcYtQEficrlisdjD\nJ+mR+E0ASexIkHgyAD2gLVRDoVDo9XqPx/N5ErupqakPPvggmUwqlUoajRYOhy9fvhwKhV58\n8cVr166Nj48rFIqqqiqw9V9eXs7lcjKZ7HGMeEOvcG1tLRqNKhSKlpaWhoYGOp0OtiAlzWk8\nHrdYLFVVVZDE+rOf/cxkMgF1cDqdRqPRZrOdPXt2YmLi9u3bbre7lLs1ODg4NDS0uzIJmMNt\n0WrAaJrX652ZmZmfn9+c3R4Oh2dnZ9Vq9e6mAH/rt37rpz/9qcPhAANnyLAXi8UdHR337t0T\niUQYhgUCgVQqxWQy+Xw+l8tdWVk5fviw8uJFRSqFIMiKWDwpk4U9HgaDcezYsbW1NSqVmslk\n8vl87lcA5xGZTMZisYxGI4IgEOC7trZWW1vb09NDo9FOnToFOla32y0QCKqrq7u6ujAMY7FY\nGxsbDocDx/FCocBgMDY2NhAEGRoaUiqVqVTKbDbH43E4HSDB0FBGEGSLNAFqnOD3ARLg0q/A\nYDmTyZjNZvgVdOHX1tZAO6xWq7ebIUciERaLtYOf8PLy8tLS0uaOMJfLNZvNMzMze/fuLd3E\nXcSpbYfT6bxz5w6TySz9UctkspWVlYmJifb29h2MV0iQAJDEjgSJJwP5fB7GwzcvhFc4VFM+\nH6RSqampqVQqVRIw8ng8Nput0+nu3Lmj1+v5fL5MJoP0UgzDGhsbl5eXTSbTwMDAoz2SUCj0\ni1/8YmlpKZ/Poyi6sLAwOzs7ODh4/PhxaPxNTk6aTCYwVIMxNYVC8e677y4tLZXy5hEE8fl8\nd+/eRRBEq9XmcrnW1laYxF9dXR0ZGRGJRJ2dnbBmPp/3+/2JRILP54vF4p0JH41Go9Pp228N\nWGMYDAYURTfTPqi/Li8vA7Fzu91QO+TxeDU1NZ9q1JJIJHg8HkRBAKEBoWsgEIBi5OTkpN/v\nh6kygUDA5XIFbDZ28WJFKoUgyAKOX0fRgt/P4XAGBgZ+7/d+74/+6I+AEwNBBzUGPG9utzsc\nDsPyUCiEoijUAkHtQaFQmpqampqathyh2+0GFWomkyk9tBiGuVyuqamppaWlQqEAbXTIUQgG\ng6Ojo7/9279dUVFhMpkgNALuVzweP3DgANgaWyyW2tpauBfxeDwYDB46dCgWiwUCAZVKVRoD\n4PP5ZrPZ4XCcO3fu9u3bJpOpqqoKhLTRaDQcDp86dWqHEqnf74/FYltWADNkn8/3aKXWLpcr\nGAw2NjZuXlhWVuZ0Ol0uF0nsSHwqSGJHgsSTAaFQyOFwIpHIlkoDm83+PP+v9/v9wWBQLpdv\nXigWi+12++rqajwe35IEABP0pVGtR4jR0dH5+fna2lp4eRMEsba2Nj4+XlNT09jYODw8rNFo\nnE4nGBTX1tZC3OrKyopQKNx8DWUyGXCLTCZT4nClUFqtVgsLV1ZWbt68abfbIee+sbFxaGho\nB75Fo9Hq6urMZjP4vcHCVCqVz+dVKpVWq90+NodhWCQSIQhidHT09u3bJUc6kFwcPHhwh0nK\nq1evgnQ0HA4Xi0U2mw1WwAsLC93d3TqdjslkisViFEVzuZzP53OsrtZeu+ZaXUUQhH/8eHlH\nx+DqqlKp3Lt37/PPPw/eyJlMRiwWEwQBtbpcLhcIBHK5nMvlglBUqOel0+lCoQCCBijafeIR\n6nS6QqHQ0dGRTqcTiQTU8KD3fevWLYvFAkpYBoMBqRWBQODWrVuvv/76iRMnRkZGgKMjCMLj\n8QYGBoaGhths9lNPPXXjxo2FhQWwcaHT6W1tbcPDw+++++5m82fkV3kSBEFUVVW98sor3/ve\n9+7evZvP5ykUCovF6unp+c53vrPD5YUvKltWADOaLQFfD498Pl8oFLYY+sCXhFwu92j3ReJL\nCZLYkSDxZKC8vLyxsXF8fBwca8GLdXV1tbOzc7NPxP0AncF8Pi8SiT7Rsv8BUSgUoHKz/Vdg\nGPuJ4Us72849IDa/qhOJhMlkgspTae9VVVXz8/NWqxWqHQqFYgvxglDU7YIJBoPh9Xq3hwRw\nuVyv1wuNvLffftvpdJaVlfF4vEQiMTo66vP5XnnllR2sa/ft22c2m6empigUCuQZUKnUvXv3\n9vb2QizBlvWTyaRQKFxcXLx69Wo0GuVyuVBg83g8V65cEYlEbW1tm89lMzU0Go0EQTQ1Nfl8\nPsgHA9EAk8msr6+fnZ3l8Xg4joMal4thdXfu0ONxBEHav/WtY//yL8g2TiOVSuEZA6YFhUA6\nnV5dXc1gMFKpFIVCYTKZQD2z2azL5bp27dq3v/3tLcy+hFQqVSgUWCwWi8Vis9lwF5hMZjqd\nNplMyWSypqam9JzApCDUrmCEFIxLcBxXKpVlZWUOhyOTyVRXV587d85gMHg8Hg6HU1FR0dXV\nBeuIxWKQYkArNhaLcblcSKHIZDINDQ0ikSiTyUBds7a21ul07pASIRaLWSwWaFlKC0OhEJfL\nfeQzBjAOGI1GN1/JaDTKZrPvd21JkNgMktiRIPFkgEqlnjx5slgs6vV6h8OBIAibzd67d+/J\nkyd3lnYWi8V79+6Nj48HAoFiscjlch/GJAUKh+FwGLweAJBtVV1dHQwGV1ZWNr/qAoEAvFB3\nsS9ALBabmZmxWq3xeFypVLa1tTU3NycSiXQ6vWWkCZhlKcB0O1gsFoyabVmezWa5XO72timM\nglGp1KmpKYfD0d7eDowW9BnLy8vz8/OHDx++3+5kMplSqZycnFxfX0+lUmCTVlVVJRAINBoN\nmKWVrpXX62UwGM3NzVqtFsbXwuEw+O4KBAKXy6XVatva2lKp1MzMjF6vj0ajHA5Ho9Hs27eP\nzWZDbgSNRlMqlSKRCLqiLpdLIpHgOF5VVRUMBu/evZvNZnE6/bTPJ4vHEQTR/PZvfyKrQxBE\nqVSy2Wyfz1e6LMDkksnkzMwMlIpLVB6CuaxW6/bw1hKgXggEC5aAVAIULdtlEFQqtVAoQI1K\nLBbv378fQZBisTg1NXX58mWfz5fL5TgcTnNz8/ZMEaFQWFtby2Qygf/RaLSysjIOh1NZWen1\nenU6XXNz82ZGbjAYJicnOzs77/dH0dDQUFtbq9VqVSqVUCgsFosejycajfb39+/A7HcHtVqt\nVqsXFxchAANBkGg06nA49u3b92gDykh8WUESOxIknhiIRKKXXnrJZDIFAgFQzDU2Nn6qBG9i\nYuLSpUvJZBLSMMEkJRAIPPfcc7uQBYAf2Mcff+xyuSCANRqNWiyWpqam1tZWHMeDwaBOp5NK\npaAcTCQSfX192yeuHhBer/ftt982Go0MBoPBYKysrGi12sHBwf3796Moul3GCCrd+22NyWS2\ntLRcunSpREwJglhfXxcKhVVVVQsLC5BPBStns9lEIlFbW5vJZOx2u1Ao3Hy5MAyj0Wjr6+s7\nHPzc3NzCwkJDQ0N/f7/P55PJZB6PZ2ZmBnQG6+vr8/PzICYA2tfb29vZ2fnOO+94PB4WiyWT\nyaAB5/f7U6nUwsLCmTNn3n777fn5eTqdjuO4z+dbXl5eWVl58cUXKyoqlpaW1tbWIpEIpIfx\n+fxcLgeUOplM+v3+UCiE5HKnEglZLocgSH7v3qf+6Z+QTUVQHMdL5wg7pdPp4FFHEATU7UAh\nWywWwS6EwWAAvcvn88lkcgdh6Z49e0ZGRmKxWDweh4+k02kcx9vb2+Px+O3btyORCIfDgU4u\nxJSJRKIt42tTU1Pvv/9+LpcDHW4kEhkbG4tEIufOndt83xsaGsAvZv/+/SXNh8vlgq8EW/xT\nkE3TciqV6hMPHsfxs2fPslgsg8HgdDqpVKpIJDp27Njw8PAOD8DugGHY6dOnCYJYWVnJZDKw\n966urlOnTj2SyjeJLz3Ip4QEiScJNBqtpFp4EMRiscnJyUwmU/qUSCRyu90LCwtdXV0P0sPd\njsOHD2ez2Xv37ul0OjAh6+joOHHiBI/H27NnD4qiY2NjMCkvlUqPHDnS39+/6xfSzZs39Xp9\nY2NjqTi3trY2MTFRV1enVqtHR0dlMlmJirndbj6fv7NA+MCBA16vd3FxcX19HUXRZDIpkUgG\nBgb27t2bSqUMBoNUKoVpPJ/PV1dXt2/fPqhIbSfB4HC7w760Wm0ymWxraysUCnw+n8Ph1NXV\nzc/P63S6lpaWr3/9601NTRaLxe/3y2Sy+vr69vZ2Go3m9XoTiURpTp9OpyuVysXFRZ/PNzc3\nNz8/r1KpSnQnFotptdra2tr9+/e/8847a2tr4OEHbWs+nz8wMOByuebn53O5HLVQ+FoyWZ3P\nIwgyj2HC3l4Mx9Pp9MzMjFarjcVioDLp7+/n8/krKyuxWIzFYonF4mKxGIvF0ul0LpeD1cB2\nDvryFArlft6Bm9He3v7UU09dv349Go3G43EMw6DeNjw87HQ6r1y5Eg6H3W43lB6ZTCaDwWhv\nb9/sWZPNZmdmZjKZTMk9Bxz1jEajXq/v7e0trSmTyU6ePHn16tXV1VWYDeBwOL29vUeOHJmc\nnNx+nDQaDc5oh+NXKBQvv/wy2LXQ6XSFQrGDivYhoVKpXnvtNZ1OFwwGIfZXo9E8vIsKid8Q\nkMSOBIkvMzweTyAQ2Px2RBBELpcvLi663e7dETsWi/Xss892dnaCD61IJKqvry/1sDQaTWNj\nYyAQCAaD1dXVDzPPF4lELBaLRCLZ3HJVqVTz8/Orq6uHDh3yer1Go5HFYkGPj8lk9vX17Ux8\neTzeK6+8Mjc3t7a2Fg6H5XJ5U1NTY2MjhUL5+te/Pjo6ury8HI1GMQw7cODAoUOHIG5LLBa7\n3e7NjTBoPu4gnshms4FAYLvdCYfD8Xq9CILQ6fS9e/fu3bt38wrFYhFFUSqVWkoGQ1FUKBTC\nbJzRaKRQKJu3yeVyURQ1GAwcDgcG/DdrFwiC2NjYMBgM8XicThBfz2ZrCgUEQe7S6RcplD6D\nIZlM/uIXv5ibmwNft1AoZLFYzGbziy++GI1GQVqbSCSKxWImk4EfM5kMRIrB0eZyOQqFQqVS\ni8Uik8nc3KDfAolEIhaLoVAHggyQoTQ0NKjVaqVSCeOM8B0gnU6LxeKhoaHNYwbBYBDs8TZv\nls1m53I5v9+/ZXcdHR18Pv+jjz5yu904jjc2Np4+fRouJswIlmycEQQJh8McDudTm6p0Or2h\noWHndR4VcBzv6en5fPZF4ksGktiRIPFlBlSbHodJCkwCfeKvkslkJBKJRqNgD7brVIxUKgXd\nus0LgUYkEgmlUnn+/PnJyUmz2ZxKpdRqdUdHR2dn5/1UmSWgKNrX19fX17dluUKheOGFF8Lh\nMMyBCQQCOHIKhdLZ2QkyCAzDgGwlk8na2trW1tb77YVGo0GDcsvyfD6/w0wkhUIpLy+/ceMG\nlJqg9gY5B5WVlVDo2vIRDMOSyaRer4feZTweLxQKVCqVw+EQBAGGIHSCeDmbVRcKCILMMhiX\nMQwpFBwOx8TEBASdlYTVqVRqaWlpYmICdBuFQiGRSEDvlcFggD8I3FOo1dHpdBiGgz3ucNmX\nl5dtNlt7e/u+fftCoRDEZHk8ntu3b6vVajabDYmxILAQi8UcDmfL1QP96Sc+TtulqXq9/sqV\nK6urq7AREFKcOXOmsbGxpqbGZDKBnhrcW2Kx2MDAAClNIPHlAEnsSJD4MoPP57PZbBh1Ly0E\nfrBDcWXXgNn2iYkJn88HXU6NRnP48OHdKQdxHMcwbMvYFgx7wekIhcJTp07tIhyMIIhYLJZM\nJgUCwWaqRKFQhELhdvuY1tbWixcvms1m8NQF++Kenp5S23d6enpubm5jY0MqlQ4ODra0tIDd\nicVi8fl8Pp/P6/WWlZVJJJJsNruDXxqFQonH49FoFEVRBoMB5CmbzUaj0VgsplKp1tbWtnwk\nkUhUVVWtrKzkcjkulyuVSoHKJ5PJYDBotVqjweBLmYy6WEQQRMtijYtEQhotEAjEYjGz2ZzP\n5zefL47jXC53eXlZIpGk02lQwoI9Xi6Xy+fzQMigGwttUwaDAXpbFou1w7cFaGJCAhg0phEE\nSafTCwsLN27csFgsOI6jKJrNZnEcr6+vB+nrZpkOh8Ph8/mgCClt1uPxuN3ue/fuFQqFsrKy\nzs5OiMS9dOnS2tpaQ0MD3F+fzzcxMcHhcM6cOXPmzJmPP/4Yvg9QKBSRSPTUU0/tIIIhQeLJ\nAknsSJD4MkOhUDQ1Nd26dQtszBAEicfjZrO5paVly/z4I8HExMTFixfz+bxCocjn89ls9saN\nGxsbG+fPn9+FCBf8527evAnSTlhot9tFItHmIE5Qaz74Zu12++joqMlkSiQSQqFw7969g4OD\nO3vMzszMRKPRvr4+cHeDfHqn07m0tFRfX//3f//3V65cAdExjUZ79913z549+7u/+7t79+59\n991333jjDRAcQIjW8PBwV1fXDvvyer10Op3H45VmqrLZbCQS8Xq9zz//vFarvXXrViAQ2NjY\nEAgEUqlULBZrNJo333wTVKLIr7qxLBbL5/NlE4kTbreyWEQQRMfh3BKJqL9yXwMjuu2TW0wm\nE3xAwDAFtgY0Lp/PMxgMODYoneI4DucFqcE7VGej0SiNRtuyAsR8+f3+YrGYz+fhwDweTzKZ\nbG1tra+vB5O8hYWFe/fuBQIBp9Npt9tzuVxdXR2Kolqt9u7du5Ag4vV6mUymVqt97rnnTCbT\n+vp6U1NT6exkMlkqldLpdIcOHVKr1a+99prJZNrY2EBRVKFQ1NTUfP5pyyRIPCZ8TsTOdO1n\nP/l4ct0XOvhf/uXrjIlpV/uhVtnns2sSJH6TQaFQTpw4kcvldDqd3W5HEITJZLa1tZ08efJh\npt8+Eel0enp6OpfLNTU1wQiaWCyG2falpaWd2cz9MDQ05Pf7QRWLoigYIA8ODu561Mlms/3r\nv/7rzMwMNO+KxeLMzIzFYvnmN795vzwocN+FCtzm5ffu3TOZTHfu3HnvvfdoNJpGo4F8LYvF\n8uabb1ZXVxMEYbVaIfoCOpvZbHZ5edlsNt8vbD6fz0ciEYVCwWAwwuEw0EGhUMhiscLhcEND\ng8FgmJmZSafT0AzFMKyrq+vP//zPwdpw8+hYJpOhFgpHHQ5xPI4gyCyD8SGCEKEQMBgqlapW\nq6VSqclk2nIMiUQCbhybzS4Wi9BmBZ5HpVLT6XQ8HkdRlM1mKxQKmAgE45LKysod6DuHw9mu\nTgiHw6FQiMPhrK2tpdNpLpfL4/EKhYLf719cXARHtw8++GB8fDyVSkG0RrFYhGJbLpezWq0o\nilZUVITDYSaTmc/np6amhEIhpJYBqwO7E+DKEDLB5/MxDOvo6Lj/Y0KCxBOMz4HYET94bf/r\nb0zAD6w//8fT8X98as8HB3/nn0b+9XU6+R2JBInHDIFA8NJLLxmNRvAkE4vFLS0tuzOx24xM\nJgNGuCVPCr/fD73IzavxeDyr1bp9tv0BIZfLz58/f+fOHYvFkkgk5HJ5e3t7S0vL7vJbEQS5\ncOHCjRs3mEwmj8cDKUAoFLpw4YJGo3nqqac+8SOpVCoWi20fIMNxPBAI3L59O51Ot7e3w0IU\nRRsbG+fn569duwYmI2w2Gy4Uk8mUSCROp/PDDz+8H7EDS2HgIsivRscKhUI2m8Uw7M0331xa\nWqLRaDKZDLq0yWTSaDS+8cYbvb29RqMxFAoBA87lcsVM5mvJpDiZRBBEy2K9TxBIsbj54A8c\nOKDRaLRard1ur6ioAMIXDAZzuVxbW9vCwkJ5eTmGYR6PJ51O0+l04I4oip44cWJiYgK6vTDE\nCSxwYGBgh28LVVVV0EgVCAQbGxtQ3QRjYRzH4UdQTsB4IsRarK6uTk9P4zheYtU1NTV3796t\nqqoSi8Xr6+tMJtPtdkPACZC5O3fugJZ5bW3NZrMlk0kqlSqRSAQCAYhtH+hBIUHiicVjJ3aW\nN599/Y2J4df/4b/9/lc76ssRBBHW/81ffyv4p//6nTN7hi/9p126W5EgQeLBAfUkjUbzSLZG\nEMT8/Pzt27d9Ph/4xnV1de3fvx/6aJ9IuYqbKMVnBY/HGx4eHh4e/kTPkc+EeDw+MTGRz+dL\n6aIcDofNZi8vL4+Pj9+P2KEoCqW4LcvB68Tv95ccdwHQoLRarYFAAPqzoDDIZrMOh4NKpS4s\nLOxwkOXl5WNjY/F4vKS98Pl8mUymoqLi0qVLoBrJZrPgXczlcl0u16VLl/7sz/5Mr9f7/X4I\nckUplK9EIspkEkEQ9vCwIRxWbGxAVhXQJhCBtra2Dg4Ojo6OjoyMAImUyWT9/f19fX0jIyOZ\nTIbP5wsEgmw2S6fT2Ww2zPm9/vrrcrn8+vXr2WwWKpEUCmVwcPDgwYM7nFdLS0tLS8svf/lL\nl8sFNA7DsPb2drlc7vF4+Hw+QRChUAiCejOZTFVVlUwmW1pa2tjYKEW9we2Aamgmk4lGoxKJ\npMRKc7mczWYzGo2HDx/2+/0GgwHm/4rFotFozOVyR48e3fLFgwSJLx8eO7H7v//wqqj5T0a+\n/93/tUtW05/8y3h2QvJf/vNfIf/pzcd9ACRIkHi0mJmZuXjxYjQaFYvFdDo9Fot98MEHfr//\nmWee4fF4oVBo8zA+hFI8ktilh2R1yK8af2w2e4vVMIIgbrf7fp9CUbShoeHjjz/ebF8ciUSg\nOfuJKWrQfnW5XKlUSiKRwDoQtxoMBne2Na6oqCgWi1DjhH4rgiAcDqe8vHxkZKRYLG5sbEB7\nFJgu6Do1Gs3AwMDExEQ6nWYgyCGrVRmPIwiS37s3fPhws9GYz+c9Hk8qlcIwTCKRsNlsiB1T\nKBShUAicjSFMQiqVYhjW2dn585//3GQySaVSHMfz+bzdbicIorm5WSgUKpVKGo0GIlYwWmOz\n2TLZTgM26XQ6mUzSaDS5XJ5MJjEMA70F+AwLBAKhUBiJRGAeUSQSdXR04DgOdipbBuAgAMPn\n86XTaYlEUvot0LhoNAoBaGCnAt1bBEFghu9TRdMkSDzpeOzE7heBVPMfvLR9+dnz6v/rTy4+\n7r2TIEHi0SKdTk9MTDidTgqFAm96HMeFQqFWq+3q6urq6vrwww/X1tYUCgWYqNlstpaWlpKj\n7K8XTCaTTqcnk8nNC6HQuHNvemBgYG1tzWAw8Hg8DMMg0Kyrq6u/v7+xsfHKlSswDAcrJxKJ\nQqHQ1tZ2+/Zt5D8ay32qEW6xWFxeXoaGLBARCoXCYDDodLrJZAI9CofDKfFLcIPL5XISieS5\n557T6/UrS0tH7HZJPI4gSKGnx9HT45ufVygUarXaZrNB5GhVVRUM8BkMhn/4h3+ABDM+n18s\nFi0Wy/e//302my0Wi5VKJZVKjUQiQC5RFOXxeJWVlSaTaWZmpqKiore3N51OM5nMWCy2srIy\nMTFx5MgRuKSBQCASieA4LpVKYdZtcXHRaDT29fVxuVwIXSUIQqvVSqVSpVI5MzODYRhM0eXz\nebVaTaVSZTIZOAVujglGEAR4IYZhKIpuzlSFPAyxWKkUPWYAACAASURBVByJRKRSaU1Nzfr6\nejqdptFoEAVGpVJ9Pt8O7oMkSHwJ8NiJnYpJi61Ety/f0EdozN3HR5IgQeLXAp/PZzQanU5n\nNpuF0pff7w8Gg3Q63eVyHTp0KJ/P37lzZ2VlJZVKiUSinp6eY8eObWlW/roAEaKTk5ORSATY\nQLFY9Pl8EDW2wwdlMtnLL788MTFhNBozmUxZWVlHR0dvby+LxXrhhReMRqNOpxOJRKAzDYVC\nTU1NJ0+e/PnPfx4KhSKRCIZhoPpMp9Moiu5gNEOhUEwmUzabFQgEIAiFlmU0Gl1ZWREKhTab\nbcv6xWJRIBDQ6fS1tTWP3f6UzSbe2EAQJNzUxHvuuRo63e5wQPKY0+lMpVJMJlMmk4nF4iNH\njly/fn1ubg7oZj6fhy6tyWR677339uzZ09LSUlZWptfrE4kEhmFVVVX19fWhUEin0wUCATAu\nAUKM43gkEllcXDx06FA4HL5586bBYEgkEiiKlpeXHzx4sKWlxe12QyYv8qviK1QHaTTa+fPn\nM5mM0WiEJLTq6moajSYWiwcGBrhcrkwms1qtarUauF08Hg8EAocPH+bz+aB1TSaToJZIJpMc\nDqehoQHYcHNzc21tbTKZBN1uJBKBiuDDP0gkSHyR8diJ3f/RK3v1/z0/9f/o+yT/6wtx0nX9\ntZ9ZJV3/9rj3ToIEiUeLTCZjs9ni8XjpRSsQCMLhsMvlstvtKIqePHmyo6PD6XRubGyoVKra\n2tovzrg6nU4/c+bM6upqOByORqMIgkD9rLOz834DdiVIJJIzZ86cPHkyHo/zeLxSHa6vr+87\n3/nO9773PYvFAgqJ9vb2P/7jP25ra6uvrwflQSQSgbYpm81msVhtbW332wtBENFoNJvNplIp\n0KIiCAIK0Egk0tfXt7KyEg6HweUun89DDkRnZ6fP5/vFT35Sdf06aGBdKtU9uVxy925PT0+x\nWDSZTNFolMFgUKnUeDzudrvBAnBsbAxUomw2G2Jh4/F4KpWanZ1VqVRWqzWfz4OEIpfLJZNJ\nk8nEZrMDgQDYnWw+cg6HE4/HvV7v+++/v7i4KJfLpVJpNpvV6XQ+n++rX/1qNpvd3kyHibqm\npqa/+7u/u3z5MoTUYRimUCgOHjwIkpSDBw+Ojo7Oz89DZ5ZKpUI6WTgc7urqcjqdmUwGGLNc\nLi8UCl1dXRC14nK5XC5XJBJBUVQikTAYDC6X+wX5jkGCxOPDYyd2z/7s3/6i6rcO1XS++u2X\nEATR//R//lVY+z9+8KazqPzp2y887r2TIPElQygUunv3rsvlghz0rq6uz7mvlM1mgb5sfq+z\nWCzoCcKPZWVlcrk8Go1ud/r9tePQoUPxePzq1atOpzOXy0E66pkzZ3YwDd4MBoOx5aR8Pt/y\n8nJNTU1NTQ00ZEEeodFoOjo6xsbG6HQ6+BLDZBiDwdgsBdgOCHKIx+PQI4YJM1CldHR0OBwO\nq9Xq8/mAJ1VUVNTV1XV0dMxNTzPfeksajyMIEqirC/T1KQsFp9NpNpshS4MgiEQiAZuCsbaF\nhQWPx5PP5/l8PtxNGo3G5/MjkUgwGAyHw16vt76+vuQCw+fz9Xp9MBjs6urK5XJAm2KxGPRb\nEQQRCoVGo9FoNG7O9hWLxVqtdnJysrKyEsqWm4ODI5FIeXk5n89HUfTcuXPgzwcbLDXHDx8+\nXFVVpdfr3W43l8tVqVTd3d04jovF4gMHDty+fXtjY4PJZMLGGxoahoeHCYJIp9MfffQRk8nE\nMKxQKFitVgqF8vLLLz+Scc/t8Pl8Wq3W6/WCMV5XV9cjtxMiQeIB8diJHS49dW/h/f/t23/4\nw//2nxEEufl//uEohaZ56oX3vv+Dp5Xkc0+CxGfAysrK+++/b7FYoF4yNze3sLBw8uTJnYnC\nowWO4yKRyOPxwJgUgiCZTMbn80HL7DHtNJPJ+P3+dDotEAi2RIV+VjCZzLNnz7a2tjocjmQy\nyefzGxsbH+bIJycnTSaTRqMpzb3FYjGdTjc3N1ddXS0UCiGuFyp2oEXdITwezJZhCA/IFtA7\nOPLGxka9Xt/V1ZVOp/1+P7jNBQKBRrVa/0d/xPN6EQQx8PkzTCa6tAStYbPZHAgEoM1KoVBA\n64AgSKFQmJmZgUG3LRNskB6GYRi0L0EUTBAEBMRBYczhcBgMBnA5BlMSgiBeffXVUCgEmWCb\nz0gikbhcrsHBwcrKSqPRCMYlBEE4HA4ol8IQHnRmP1G1Wltbuz3XGDwaq6qq5ufnvV4vjuM1\nNTW9vb0CgcBms1GpVNhsKQ8NMkvgZAOBwOLiYjAYhOpge3v7dqPmB8fCwsJHH320trYGVU9g\n9mfPni0vL9/1NkmQ2DUeN7ErZjI5vO7kW9dP/g//qt7iytPwinpNheAz2MSTIEECQZBMJnP1\n6lWr1drS0lJ6YxmNxpGRkerq6seRD/aJ4HK5zc3NkNZqt9spFAqNRgOjWuh/PXJA1oLX6wXd\ngEajGRoa+tS89h1AoVAaGhoeSZp7Pp83m808Hm9z9AU0+8xmM9ALmPeCaTkQsZpMphMnTsDK\n6XQ6FouVtlDKPC2ZuiEIAg5t+Xy+qqqqra1Np9PR6fSysrJUKhUMBtuamgL/9b8WjEYEQfRc\n7gUKpWC3U6nU9fV1DMNqampyuRwY0VGpVOggg1uK2+3u6OjQ6/WBQIDL5dLpdKgU0mg0tVrN\n5/PVanU2m/V6vUAHuVxuXV0dyGIgQxYC2fL5fDgchicBQsa2XCUQ8Eql0tOnT1+4cAH6vywW\nq7Ky8tixY4ODg7u+/hQKBVxUtljhrK6uoih66tQpyIFlMpl8Pp/BYIABjcPhuHLlCkh/QDcz\nPz//7LPP7u6hCoVCV65ccTqdGo0Gpg6SyeTS0hKbzT5//jwpwiXx+ePxEjuiEBOwhL1vrdz8\nWi0urdkrrXmsuyNB4ksMu92+vr6uUqlKpQU6nV5bW2uz2Ww22+dWtIP412AwqFarofkFo/2V\nlZVbghkeCRYWFt59992NjQ2lUsnn86PR6MjISCAQeOWVV+4XFPH4AHlWkH5RW1srEolyuVw2\nm90+RIiiaCwWm5ub83g8MpkMWtUg4XS5XNPT0wiCBAKB8fFxnU4Hus729vbBwUHoioLeM5PJ\nQHmJyWSmUimPx/PjH/+YzWa3tLRkMplkMimXy5vr6vx/8zfO0VEEcmAlEimDkU6ngczFYjGZ\nTOb1eqEBWlLjUigUyIo4fPjw4uKi2+12u93AjXAcVyqVw8PDZWVlPB6Pw+Fks9lwOIzjeFlZ\nGQhjg8FgeXl5U1OT3W7PZDI4jldVVdHpdI/Ho9FogINu7reGw2G1Ws3j8TKZDDwzuVyuUCiA\nF93DeByWsIVNgvBZJBJt5mrhcDgcDq+vr1+9etXtdjc3N8ONi0Qic3NzXC73a1/72i52bbFY\nHA5HfX196TFgsVhlZWVWq9XlclVWVu7+rEiQ2BUeL7Gj0Ph/2Cz68f+8g3xtaxWdBAkSnwnJ\nZBJ8uTYvxHEcIp4+t8OgUChHjx6NxWIGgyGTyYDvrkqlOnr06CNvxRYKhYmJiVAo1NraCr1C\nHo/H5/OXlpZ0Ot39whseBwqFwvXr16emprxeLxgOq1SqoaGh7u5ugUDg9Xq3rJ9MJhUKhdfr\nJQiCw+FAHY5CofD5fL/f7/f7A4HAD3/4w1u3bpXCwaCl++qrr+I4zuVyMQwDsWoqlYrH43Q6\nncFg0Gg0p9PJYDC6u7ubm5uFHM7kt77lvHkTQZBQQ8OVcFjIZPJ4POBt8Xh8Y2MD1AZAoaBo\nBylhQBnb29tVKpXP52OxWLAEfOZ6enpwHPf7/ffu3cNxnMViZTKZ+fl5Npt99OjRYDCI43hj\nYyNkuUKv1u12p9Pp6urqyspKg8FQW1vLYrEKhYLdbqfRaHv27HG5XBcuXFhcXIQhPyqV6nQ6\nP/jgA6FQCCYpZrNZr9d7PB4ul1tVVdXV1VWKRwuHw7du3XI6nVCy/dR4OvjgljIeKILdbrfT\n6WxqairxMD6fL5FIlpeXA4HALhr98Xg8l8ttSStms9kw2vhZt0aCxMPjsc/Y/fnYpfnB06//\nI/6X335azCSL0iRI7BKlKs7mVwiEuJfef58PJBLJN77xjYWFBXiXS6XStra2x2Hov7Gx4fP5\npFLp5gkwLpebzWY9Hs/DbBnEpzBj9yCVv9nZ2atXr1KpVI1GA2lXFovl8uXLIpGora1teXnZ\n7XYrFAqgaDabTSAQQG0VRdFEIlHiGYlEAnQn165du3TpUiqVKmkjYrHYxYsX6+vr6+rq7HY7\nj8dLJpPZbDaTyYBbSnl5uVwuZzAYt2/fnp2d1TQ0lF+5Ql9dRRCk/Vvf+mEoJFhcZDKZ4XAY\njhnDMLFYnMvlcBwHHxPwNEF+Vd/CcdzlckEJMJvNAkXDMAzH8WAwKJVKIW0CnH6LxSKLxaLT\n6fl8nsfjQeoGlUotXb1UKiUUCtVq9TPPPDMyMmKz2UDeIZPJDh061NfXd/ny5fHxcYIgYFAP\nQRBQaVy9enX//v1jY2NjY2N+vx/H8Ww2OzMzo9PpvvrVr4pEops3b/7whz9cXl7OZDIUCkUs\nFg8PD3/3u9/dQZ1QU1MjlUptNltNTQ08PJlMxuPx9PX1gVn0liIrl8sNhUKQY/FZnyUmkwlp\nuZuLlNlsFi7mZ90aCRIPj8dO7J5+4c+KctV///2z//1/x+RKKcb4DwXz1dXVx30AJEh8OVBR\nUaFUKi0Wi0ajgRczQRCrq6sKhaKqqupzPhgmk/k5FMwgh3R7oxMqUrve7Pr6+ujo6NraWjb7\n/7H3pgFtnWf69zna911ICBCrWMW+mN3geM1mx0uc2HEmySRp2nSm6bTTPTPdZ6bvf9JM2qZJ\nO20znWnjNE4TJ7HrfcHGZjMgFgkEEgK0gNC+73o/PImqgi0TQHh7fp/wQeech2MQF/dz39cV\noFAoZWVlzc3NYBAkEAgMDAxoNBqbzZaSklJQUACslQcGBnw+n1QqBVcgEomFhYUymWx0dHTb\ntm16vf7EiRNXr14FIgyIm9ra2tTU1IWFBQwGA9yAQS4CmUwWi8VnzpzRarVgixZcE4/HWyyW\ns2fPtra2ymQyFEVFIhGoBoFCWkFBgcPh6Ovrs9vtSDAo/MtfcDMzCIJEN2wo/s53iN/6FoVC\nycnJcTqdQGTQaDStVgtiP4hE4icBspEIcFEBw7BarZZAIGzbts1ms4GCFpPJBFbMdrudy+UC\nIxXgY8fhcDwej1qtbmlpoVKp8/PzAoEALN7j8djt9oaGBhKJJJVKxWIxmMalUqlpaWlgWGRo\naMhqtebl5ZHJZPD3CYPBmJiYGB8fl8lkly5dCgQCwBsPQRCn0ymTyfh8fkVFxauvvqpSqTIz\nMxkMRigU0ul07733HoVCeemll270X5ydnd3U1NTR0SGTyeh0OtiYBgOzSqUSWeJ4HAwGgSn0\nCr6dxGIxn8+fnZ3Nzv6k1ygSiczOzubn54tE0KsVcgtIurAjkUgIInrgAfj9DYGsCgqFsmnT\nJrfbPTQ0RKfTQSRASkpKa2vrKgdFb1uYTCaDwTAYDPGbvEAJrXh4QqPRHD58eGZmBhhq2O32\n48eP6/X6AwcOhMPhI0eODA0NgX64wcHBvr6++vr6trY2i8USizcAYDAYEokE7EKAzwsOh4uN\nR4AjdXV1ExMTHA4Hh8O53W4ajQZSEKqrq99++22fz0elUoF5CvAiAU333//+91Uq1fnz5202\nm8vl8vl8TCazqKgIlAZNJlOGUCg+e5ZotSIIgmtuVkqlfdeuFRUVDQ0NBQKB2LMC8RhFRUUO\nh0OhUEQiETKZHBvOQBAkNzfXZrMRiUTgBhw7TiaTvV6vyWQiEolcLjf+UyAkLS8vr7a2tre3\n12g00mg0EH1RWlra3NwMXsZgMJbulgLFGV9dRlGUTCa7XK7x8fGFhYWYqkMQhE6ns9ns8fFx\njUYzNTVVUFAATgSDHQqF4ty5c0899VSCmaEtW7aIxeLBwUGDwRA/MOvxeNhstsFgiKmuSCQC\nRh9iOnUpXq/XarUCs5v4yhyCIOnp6fX19RcuXBgeHmaxWCDzTSQStbW1wYod5JaQdGH30Ucw\nNwwCWRvKysrYbHZXVxfwiSgtLa2trZVIJLd6XcmCRCJVVlZqtdrZ2dm0tDQwijs5OZmVlZU4\nKCIBly9fnp6eLi0tBb+eeTyew+EYGRmRyWR2ux0Y8wK5APw4Ojs7hUIh8JZbdClQTezu7u7t\n7ZVIJPX19eA4OCsjI+PgwYNjY2MymQxMXwJVV19fv3fv3t/+9rfhcDi2mYiiKI1Gm5+f93q9\nTCbzsccec7vdPT09oAQoEolqa2tJJJLZbCZhsbkdHUyrFUEQfEsL+eBBmkqlVqsfeOCBWK2R\nRCKB6QqxWLxr1y61Wi2TyWw2m8/ni2WUsVispqYmHo8H8sTiAZuqPB5vdHR06adSUlJoNNru\n3btzcnJGRkYWFhbodLpEIqmrq4t5/4KsW1Cx4/P5oBIGBm+9Xm9M20WjUY/HIxKJwCztIsdj\nKpXq9XrBTO6iZgMOh2Oz2RLPDKEoWlhYWFhYuKjTLi8vr7q6+vLlyyCgNhQKmc1mkUi0cePG\nRYoN4PP5urq6enp6nE4naEBsamoqLS2NX+2WLVuEQmF3d7fJZMJisSUlJQ0NDbECHgSyziRd\n2AE8usEjR0/L1XpPGJeaU7J1197qDNr63BoCuZvIyMgARq+ghf9WLyfpNDc3e73e3t5ekEkA\n9kDjBzUikYjdbvd6vSwW66bdci6Xa3Z2lsvlxj860DE2NTU1NzdHoVBiRSAURTMyMgYGBrRa\nrVgs7ujoEIvFMYkA8r4yMjKA+Uh8WSs9PX1wcFCpVFZVVf3oRz967bXXenp6zGZzSkpKS0vL\niy++CPIPUBR1u90xbed2u4GliNFo/Pjjj51OZ2trazQa7e/v12g0vb29ra2tSDBYMTDA/LRW\nRz54EEFRIDqlUumXv/zlw4cPT0xMuFwuCoVSUlKyd+/eDRs20On0lpaW6elpr9cLNlXpdDqP\nx6uvr8fhcH19fUajMfY8nU6n1+stLCwUCAR9fX0GgyHmYuN0OsGqQIdcTU1NTU3Not4yBEHm\n5+dBpJjH4yEQCCKRqLW1VSqVVlRUnD171mQykclkDAbj9XqdTicwiOZyuUtnY0HPX2wGPBwO\nBwIBLBaLx+MjkQiKouC+gUBApVIBj+LU1NSlu5+LBmYxGMyDDz4I0mkdDgeZTK6vr29ubr6u\nQ3UkEvnwww+vXLkCguDC4bBcLtfr9T6fL74VAXhHl5eXu93uFW/pQiBrxXr8YnjvXx47+KM/\n+SN/3QL49ksv7Pv2H975/p51uDsEcveBwWCWuoXdJrjd7mvXrs3MzFgsltzc3NLSUrFYvOKr\nEQiEBx54oLS0FGwCstlsiUQSE0Nqtbqjo2N2dhYE11ZUVDQ1NSXIjAqFQqDXbdFxHA7ndDo9\nHs9SaUgikSwWS3t7+9TU1PDwcGpqKolEcrlcRqOxqKioqKiop6dn6VkUCsVsNgcCgcuXL6Mo\nmpWVxePxgN/HlStXtm3bVlpaCrxCwEAAgiDRaJTJZFZUVICk3ZKSEqBpaDQajUZTKBTRQKCk\npwfkwEbq6ihPPIGgKIIgDodDKpVisdjGxsaCggK1Wu10Omk0WlZWFpBrxcXF27Ztu3z5ssFg\nAE7FfD6/trYWpI2p1ere3t65uTkqlQqGJMrKyhobG6lUqkql6u3tlclkYBM5Go2CJ7zo0cX/\n0+FwvPvuu3K5XCAQCIVCv9+vUChAoyHoZRwaGgKFOjKZzGazmUzm5s2bhUIhk8nU6/UxWQYs\nqZubmwOBwKlTp9RqtdfrDYfDKIpSKBSbzVZSUgK8fk6dOjU5Oel2u7FYLI/Hq6uru++++xKn\n2BEIhIaGhg0bNgD75QRDGJOTk4ODgxwOJ5bvIhAI5HJ5Z2dnaWnp0qElmDYBuR1IurCbevfg\n3h+8k9H+9//vW883l+dRUP/k8JU3f/hP//2DvYSKqf/dnZXsBUAgkHVjfn7+yJEj4+PjwFND\noVBcu3Zt06ZNse6rlSEWi5eqQ6VSeeTIEa1WKxAIyGSyzWb7+OOPDQbD448/fqPeJhqNRqfT\nZ2dn472UI5FIIBAQCoV2u32pcYzf76fT6Tk5Ofv27Xv77bflcjnwsautrX300Ud5PB5Qftc9\nq6en58qVKywWq6amxmq1cjgcrVbb0dEhEolAFz+ogQHvYiaTSafT29raQB5rrFLFYrFaWlqQ\nYDC/s5NhsSAI4pJKeU88gaBoMBhUq9VcLre8vBy8eFFLHABF0fb2dolEMjk5abfbgeaLBTns\n2bMnNzdXoVDMz8+zWKz8/HzgdYIgyO7du3Nzc+VyudFoZLFYeXl5NTU1icuiMplMqVTm5+eD\nl4GkDRAp9swzz+zatYvBYIACG41GA9FbTU1NeDy+rq7u6tWrw8PDDAYjEAi43e78/Pz29vZo\nNPrrX/96bGyMSqXSaLRQKKTX6ykUSk1Njd/vf//990GeW25uLvjUyZMnCQTCpk2bEiwSgMFg\nbhp5p9frbTZb7PECwEzM3Nwc3GyF3J4kXdj9v5c+pKU9NXbm1xTMJx0JNe17qjfuiGQK//QP\n/4ns/lmyFwCBQNaHaDR65syZkZGR/Px8YLBHIpEmJyfPnz+flZWVIEdrZfe6fPmyVqstKysD\nxUsej2ez2YaGhqRSaW1t7XXPwuFw5eXlGo1Gr9enpqaC6drJyUmhUFhaWoogyMmTJ+PrdmDf\nMCcnx+fzXbt2zel0gvZ5kEk1MDCwdevW/Pz8iYmJ2dlZYDRIJpMJBAIWi83Ly5PJZJFIJDU1\nNRYRJhaLZTKZQqHYsmXL1NRUV1cX8umEJgaDaWxsrK2tHR4eji+DBYNB1dhY5rlzDJsNQRB7\nUdF8ff3C2Fg0GgX5Ey0tLbFx3QSkp6eDhkIajRYvznA4HNhUXdSLhiAIFoutqqqqqqpaNEOa\nAL1eHw6HnU7nxMQEiJFls9lgWMHhcFRVVWVlZY2Pj8/MzAgEgvT09NzcXHDlhx9+ODMzc2Bg\nAMR85eXlNTQ0cDicwcFBkHSysLDg8XiwWKxIJOJyuSwWa2RkZGpqqqioCOh4PB6fmZk5MTFx\n7dq1+vr6NfGvBsPXi752YPUcG2eGQG43ki7sDi948r/zpZiqA6AYype+WPA/L7+NIFDYQSB3\nCWazWaVSCQQCYH6GIAgGg8nNzR0dHVWpVGsr7Gw2m06nS0lJidciICRUp9PdSNghCNLY2Gi1\nWkHMLlhhWlpae3s7iEYAe7tg1w+DwfD5/G3btpWVlV25cuXq1at8Ph+MqkSj0enp6Y6OjvT0\n9Nra2mPHjp08eTIQCAAbEQqFsnHjxqKiokuXLtFoi5uJKRTKwsICn88/cOBARkbG+Pg4UMAl\nJSXNzc0cDkcgEMT7QCmGhuhHjnCBO119fbitDbVYcnJyKisrGQwG2ORdzuMCKRfA0yQvL6+1\ntXXREGiCzf1lqjoEQUKhkFar1Wg0LpcrFqRGo9GkUilQtxwOp6GhQSKRLFo2Doerrq6urq72\n+/3Avhgc1+v1BALhiSeemJ6enp+fp1AomZmZIIcDFPAWVWc5HI7D4bBarWsi7EAQWfzAB4Ig\ndrudSqWuW4gfBPJZSbqwo2Ewvnnf0uO+eR+KhfMTEMjdA/DmWPQLD4vFAmPetb1XKBQComHR\ncQwGA6xGbgSRSHzkkUekUimosbFYrIKCAtCLBvxKIpGI1+uNRqNAWxAIhGg0Ojw8jMViYxMG\noG1uYGBgfHzc6XTicLi8vDyQlAX8h1EU1el0BAIhEAgsWkAgEABdgHw+f/fu3R6PB0SKxaRD\naWmpQqFQqVRZWVlOi4X55z+zLRYEQQJVVbynnmKgKA6Pdzqd+fn5y9TKDofj8OHDQ0NDTCaT\nSqW63e5z585ptdoDBw4kMPhYGX6/X6vV8vn82Na51+udmJgQCoUMBiMSiYyOjgKhLxAIcnNz\na2trF2nfRZMHwWAwFAqBIh9IOnE6nTweD0RlLF0AKC4uX4kmJj8/PysrS6lUSiQSoBTNZrPJ\nZGpra0uGIzcEsiYkXdi9JGF+4/df6Pvh1Rr2X39cA/b+L/63kpn378m+OwQCWTdANgaYdrTb\n7cAwDHSzrbmhF51OB/4g8dIEGBovbTJbBIqi+fn5+fn5i453dnaOj4+3tLSAUhAej9fr9X19\nfenp6WAcYdHrQeiWyWRCEKStrS0ajQIDvGg0Ojg4OD4+DnZpfT5frJff6XRGIpHYAKbP55ub\nm3O5XF6vNy0tDfTVlZWVWSyWzs7O0cFB9gcfsE0mBEE8ZWWC554D0xIpKSkTExNGo3GZwq6/\nv390dDQnJycUCvl8PgqFwuVylUplV1fXzp07E59rs9lAZx6VSs3IyEhLS0v8eiwWi8Ph/H4/\niF4Ih8NgDheLxQYCgbNnz165csVut2Ox2IWFBZlMJpfL9+/fn6DoSKFQ1Gp1OBwGkRjhcHhm\nZkaj0VRXV4vFYrA/Hj8uMz8/n52dvVbOjkwm84EHHjhx4oRarQYanU6nNzQ0bN26da20IwSy\n5iRd2D195Pv/WvIPTVnlz3zx6aayPBLiVQ1feevnv1V6CK+9+3Sy7w6BQFaDXq83Go2BQIDD\n4WRnZy+tkMWTkpLC4XCOHj0KAmRBcBNwlF3NYOx1IZFI5eXlH330USzLKxgMKpVKkUhUUFCw\nggsGAgGFQgGmKxAEAVJMJBINDg7Ozs7i8XiHw7H0FCKROD8/D1IrUBQFygxFURDMsH///qmp\nKYVCARImrFar1+stKyurqalBEEShUFy4cGFmZsbn85HJ5KysLDDigMFgNm3alCsWn3zsMYfR\niCBIuLZW+Pd/j3yqJIAH8lJfvRsxNTXldDqHh4cXFhaCwSAwsSOTyZOTk0vNSuLp7+8/d+7c\nzMwM8JkTCAQbNmy47777EnwbYLFYiUQCzOFAmCEVDQAAIABJREFUTC2dTi8sLOTz+YODg1ev\nXsXhcBUVFS6Xi0ajeTye0dHRCxcu7N2790YXjEajgUAAtCqCpaIoOjU1FQgEqqqqFAqFTCYT\nCARMJhOEUlCp1IaGhtjoyeoBARJyudxsNuPxeKFQWFRUlPgHYfmAJ6BSqQgEQnZ2tlQqTTzP\nC4Esh6QLO1bBF+SncU984Vtv/Pgbb3x6kFPQ+otf/O8LhbBHAQK5TfH7/WfPnu3r6zOZTEDY\nFRYWbt26Neb7sBSQVQX2MRkMBghgcDqdwWAwgQXJimlubrbZbIODg7FuuYyMjPvuuy8jI2MF\nV/N6vaDXTafTWa1WEAuRkpJCJBJdLld+fv6JEyfig3ptNhsOh8vNzTWZTEvzzUBCK5fLPXjw\nIGhuMxqNAoGgvLy8vr6eRqOp1er33nvPYDCIxWIKhQICRcxm86FDh9LT04MeT/cLLziuXUMQ\nxF9ZGX3oISSuPmSxWOh0+k0LkzHm5+enpqZQFGWz2cC0b25uLhKJsNlsEKV13bM0Gs2xY8dM\nJpNEIiESiaBUdvr0aQaDEbNiXgqNRmMwGEVFRUaj0ev1EggENpsN8i0MBoPVai0vL7darSaT\niclkMplMNpsNjPeWFkQBoVBIKBRGIpH5+XnQuEkikQoKCphMptfr3bNnD4fDGR0d1Wq1OBwu\nIyOjubkZ6OY1hEajJSNAT6PRHD9+XKlU2u12MKJbVFT00EMPxeesQCArYD187NLbn7+geE47\ndm1UpfcjRFFOcVVRxm3qwQWBQBAEQZBz584dOXLEarWC1IS5uTnwC/jpp59eat8FsFgsFotl\nw4YNPp9vYWHB7/cDw1iHwzExMbHm7VxkMnnv3r2lpaU6nQ5Y3BUUFKx4D45MJmOx2N7eXr/f\n7/P5UBQF8hRF0cbGxoaGBo1Go1AoGAwG8LELBAKVlZW1tbUmk0mtVoNKGLiUx+OJRCJZWVkI\ngrDZ7AcffHDTpk1KpbKkpCT2mr6+Pp1OV15eDjr5QHDq8PBwf3+/gMN5/+GHZ86eRRCk9Lnn\njM3NV7u6EBQFX5rJZNLr9fX19csvgjqdTrPZXFZWBupMILJ2aGjIYrGALfLZ2dmJiQnghCIW\ni/Pz81EUHR0d1ev1sRVisdjs7OzR0dGBgYG6urobTVpkZmZSqVS73R6T1z6fz2KxVFRUgMBW\n4JkH9meZTCaHw8Hj8R6P50bCLhgMgpkVg8Hg8XjweDwYaPD5fMFgUCQS7d27t7m52Wq1kkgk\nkIqxzMdya/F4PMeOHRsdHZVIJJFIBGxV9/X14fH4gwcPrlVFEHJvsm7O9Wh6YU164XrdDQKB\nrAKbzXby5Em1Wh2NRqlUKoqiXq8XQZAzZ840NjbeKMfJ4XB4PB6hUMhms0FzFdijHBwcXLqP\nuSbEYqNWfynQG6fRaNLS0oAoAf8EIxopKSlPPPHElStXFApFIBBIS0srLy/fsGEDyC2Ympq6\ndu0aDoeLJY8Bl5DYxYEcif22jkQiMzMzDAYjXh7hcDgqlaqZmHj/tdeAqit7/vmtb7xhtdlw\nePzIyMjIyAiCIAwGo7m5efv27cvPHcHj8RQKxWKx8Hg80Blms9nIZDKJRAoEAp2dnZcvX56b\nmwNals1mV1dXP/jgg0ajkUgkLhJwTCbTYrG43e4blWClUmlNTU13dzeIGvP7/W63u7CwsLW1\n9cKFCxMTEzgcjsVisdlsLBZrNpt1Oh0Oh0swwcpkMlEUBZO8sYNqtZrFYoH0XhRFU1NT440J\n7wjUavXU1FRubi6VSnU6nQiCsFistLS0iYkJnU635q0LkHuK9RB2pmsffPPHvwge+u+3dmUi\nCHJmW+XLOOmX//WVR+vgVBEEcjsyPz+vUCiCwWB2dnasSdxsNs/MzIyOjt5I2BEIBBwOB/y9\nYolPYHRxDXuekkQoFEJRNCUlxefzGQwGMAFApVJjo5dcLvehhx7avn07EKwxxZOamiqRSK5d\nuzY9PQ267oqKiqRSKZAd1wVcc2n3PRoKBX/1qxmlEvlU1SEoymaz9+/fD0qD0WiUx+Pl5uZ+\nptwRgUAgFosDgYBWqwVHqFSqWCxOT0+Xy+Xnzp0LBoPADjAajRoMhkuXLvH5fODWtuhSwAUm\nQT0Jj8fv3r07KytrcHDQarXy+fz8/Pz6+no2mw1KoTweDwg+IpGIxWLlcjloMbzRBQsKCtLT\n08fGxvLz88F30fz8vNvtbm1tvaNjHmw229I6JYPBAGm/UNhBVkPShZ194lf59Z+3o8xnnvvk\nnYhTJZl+9fDjpz4yD019vugmxt8QCGT9MZlMLpcLbETGDnI4nNnZWaPReKOzUlJShEKhXC6P\nd4IwGo1MJvOm05S3HI/HEw6Ha2trgX51u90ghgEMPcReBpyE408cGhrq6ekRCoVA70ajUZ1O\nd/HixYyMDLAbuxQsFpuWlgYKorEnHPb56EeORHU6JE7VgU9hMJi8vLz4ktVnIj09nc/nZ2Rk\nmEwmr9dLIpHYbPb8/HxaWppGozGbzRUVFWAZKIqKRCK73T40NFRcXNzT0xNv4RaJRKxWa1FR\nUWKLODwev2HDhg0bNgDPvNjjIpPJKSkpkUhEq9Win0bcZmZmcjgcm812o5bB1NTUHTt2nDlz\nZnx8HAhNJpPZ3Nzc1ta2sqdxmwC8+sLhcHzlFQS+wfkJyCpJurD7zSPfcpMrO5SXmoSfvDtU\n/duf1P/Uuymv5eV9v/r8yNeTvQAIBPJZodFooI0p/qDX68VisQl+qeNwuNbWVrPZLJPJeDxe\nOBz2+/3hcLihoWGpt8j6AAY4lmO2QiAQMBiMWq32eDygx87tdk9PT2MwmIaGBgRBgAUJ8BOm\n0WhgK5ZCofT394OZgNilmEymTCYbHh6+kbBDEKSysnJ8fFwul2dlZVEoFLfN5vnFLyjXU3Wr\np7S0dGhoyGAw5OTkUCgUn8+n0Wg4HE5lZeXVq1fJZPKi2iGdTrfb7cARRqFQgMY1n8+n1+vT\n09PB01gOS+tw2dnZXC5Xp9OZTCYGg8Hn8ykUCh6PByVMn8+nVqttNhuJRBKJRLExnYqKCrFY\nrFAoYp8qKCi4bbOSl4lIJOLxeAaDIX7WR6/X8/n8WGAuBLIyki7sfjppz3v25zFVByDxa197\noaD+1f9CECjsIJDbDoFAkJmZOTk5CeptGAzG4/GAskpRUVGCE6VSKYlEunTpklarDQQCIpGo\ntra2rq5ulc3gMzMzer0eTEhIJJLl7MFZrdauri6lUunz+dhsdkVFRWVlZYJaCIlEikajY2Nj\nAoFAJBJhMJhQKDQ7OxuJRIhEotFoPHz48NjYGBie0Gq1arVao9Hs2rULRKzGXwqDwZDJZJ1O\nl2B5hYWFDz300MWLF7Vard/lSj1xgjQ7iyRB1SEIkpWV9fDDD58/f356ehpU0dLS0pqbm8vK\nymQy2dJorEAgQKPR+Hz+/v37L1y4MDY2ZjKZCARCdXX1xo0bYyGznxVQx01JSQG+gKBLTy6X\n5+bmslgslUp1+vRplUrl8XhwOByfz6+vr29rawMFLQ6H09TUtLrHcHuRkZFRU1Nz/vz5sbEx\nEomEoijwSmxsbEywiQ+BLIekC7twNEpgXqe9BkvBIkgk2XeHQCArICUlpa2tzWazhcNhu90e\niUQIBAKNRqupqbnppEJeXl5ubq7NZjOZTNnZ2cvv8b8ugUDg9OnTvb29JpMJaKycnJwtW7Yk\nXsbc3Nw777yjVCopFAqBQNDpdEqlUqPR7N69+0brAUmpDAbD7/dbrVbQYweEIIqiV69eHRsb\nKywsjBX/bDabTCbLyckBMweLrhYLrkhAdXW1RCKZUip7Pv95+8wMkhxVBygtLc3OztZoNCAr\nNiMjg81mIwiSlZXV29sb7zYSDAbtdntdXR2BQEhJSdm3b5/ZbAYGxTwebzX/m1KptK+vTy6X\nZ2dng4CQ2dlZAoFQU1Njt9s/+OADlUqVk5NDp9ODwaBWqz1x4gSRSGxpaVmbR3D7sW3bNg6H\n093dDSZI8vPzm5qa4ku/EMjKSLqw+2IW44dvfmf2Xz7KIP71T/ZIwPDdn4/R0/852XeHQCAr\nAIPB7Nixw+PxDA8Pg5E98Itn27ZtyzHZQlEUzMOuUtUhCHL58uUzZ86AsFEMBuN2u8fGxnw+\nH5fLTZDp1NHRMTY2FouHRxBkfn6+r68vPz//RpMfLpcrEonU1dW53W6j0RgMBhkMRkZGht/v\nN5lMVqsV1Opir2exWDMzM1qtNiMjY3p6GuhC8KlgMOj3+5fT/07G4ca+/nV7Xx+STFUHAM9w\n0cHKykqFQjE0NESj0cB+q8VikUgksf1WFEV5PN51TWQsFgswSaFQKBkZGZmZmYkXwOPxHnnk\nkTNnzqhUKrPZDLZiGxsbN2zYcPnyZbVaXVxcDMYjCARCTk7O2NhYX1/fhg0bbv/Jm5WBx+Mb\nGxtramqUSiWRSFz9X0EQCCDp30YvvPfyjyq+WlK46Sv/9HRTWR4FE5ySd//PK/9+xhz67vEv\nJvvuEAhkZQiFwqeffrq/v1+v1/t8PqFQWFZWlsCdOBn4fL6BgQEsFhvrQ6JSqcXFxXK5XC6X\nb9y48bpnuVwulUrF4XDidZhAINDr9dPT0zcSdlgsFoPBkEik/Pz8UCjk9/vJZDIGgxkeHkYQ\nBGSFLTqFQCC4XK5Nmzap1erh4WGxWEwkEj0ej1arzc3NraysTPzVmefm/rRjh3twEEEQtKEB\ns3evy+1eZxs2Go322GOPZWRkDA0Neb1eKpVaXl7e0tJy0//ovr4+EJsBzJlTUlJqa2u3bt2a\nuPE/Nzc3PT19ampqampKJBKlpaUByWg2m6PR6KInzOFw7Ha7zWa7uw17QWUUj8dDVQdZK5L+\nncSRfnn0I+y+z337u//YETtI4hR+7+13X66FdicQyO0LhUJpbm6+hQuw2+1Op3NRBxuQDmaz\n+UZn+Xw+YDuy6Dgej3e5XDc6i0qlpqWldXV1paen43A48FvW4/EgCJKbm+t2u0Em7KIbcblc\niUSye/fuixcvzs7OAjlYW1u7adOmxIbMJoPh9+3tkfFxBEECVVW2pqYPjh5VT009/vjjN03p\nMBgMU1NTDoeDTqdnZ2cvs9fearWqVCqwFZuZmRlbHoPB2LFjx6ZNm4BBceKJV4BGo/nLX/5i\nMpmABUk0Gp2dnT179iyYV018LpFILCwsXFQFvO62NRgZhpGsEMhnZT3+RMja8Y+90y+MdF0c\nGJv2hHGpOSVtG2sY2M/24+qzWSMMFgUDf8ghkHsFLBaLoigIkoonGo0mKG9QqVQSiRTvUQJO\nCQaDidvSGxsbZ2dnh4eHU1NTQbyE0WgsLi4GVsNqtdpoNILqUTQanZmZYbFYIJe2uLg4Jydn\nbm7O5XKxWCyhUJi4+hL0eI488ABQdfiWFsbBgzwUBXGuEomkvb39RidGo9GOjo5Lly4ZDAag\ne4RCYVNTU1tbW+KWvt7eXiA9g8EgFosFZ7W2tsbOIhKJyy+MKRSK+FAKFEXB1OrAwEBDQ8MK\nBmVAycrtdsePxSwsLBQUFIBeQAgEsnzWp/YbMUxNSxu2SBsQn7H33/6/t86cPfvQ37+4JWe5\n8ZE+89W/f/bfW3/5x88J72BHSggE8plgs9kpKSlyuVwgEMQqN06nk0AgJNgrJJPJxcXFJ06c\ncDgcoNUvGo1OT09zOJzEE515eXn79u0DAsjlclEolLa2tra2NiaTWV9fbzAYZDKZTqcjEAiB\nQIDP5zc0NJSUlIBzSSRSAnOTeIIez/sPP+waGEAQBN/SQj54EPTV0el0LBY7MTGRQNiNjIyc\nOnUqEAiUlJQAA2GNRnPmzBkOh1NRURGJRORy+eTkpMlk4nK52dnZpaWlWCx2cnLy+PHjVqs1\nLy+PSCSGQiGNRnPy5EkGgxEfj7F8FhYWgDtM/EEmk2mz2ZZWWJdDaWlpf3//yMhIamoqSLPV\n6XTgscMNSgjks5L0n5mA/eqBlgc/VAkD7tFoyLqzeOMpsxdBkF++8uZb48MHxTdvKIlGvK9/\n47+c4cVzZxAI5O4Gi8U2NjbOzc2Njo6mpqYSCAS73W4ymSoqKpbOAcTT0tIyPz8/MjISCoUI\nBILX6+XxeI2NjQUFBfPz80NDQ3Nzc2QyOTU1tbKyMn7zMT8/PycnZ2FhARgUc7lcICjJZPL+\n/fuLi4tnZmbsdjuXy83Pz1+BYzBQdSAxzFdRwfhU1QGIRGKCzWIEQUZGRqxWa6xNEIvF5ubm\nymSyoaGhkpKSjz76qLe3F5i9+f1+Go1WUVGxe/fukZGRubm5mAsxDofLy8sbGhoaHBxcmbAj\nEAjXDaUA0SMruCCNRtu7dy+Xy5XL5bOzs3g8Pisrq7m5eWXLg0DucZIu7A7v2ve+PPDMN/8B\nQRDjtZdOmb0vHlf+sGh+W9l9X93/p4NXn7npFQbe+vYAsw2ZP57spUIgkKTi9/sHBgb0er3b\n7U5JSZFKpTdNpCgvL0dRtKOjY25uzmaz0Wi0zZs3t7W1JW4FY7FYhw4d6u/vn56ettvtQqGw\nqKhIIpH09/efOnVqdnYWh8OB5PXBwcE9e/bE1/9wONx1g0exWGxFRcWNZi+WQ9DjObprF1B1\n+JaW2YqKlL9tIHO73dedP40xNze3dLqCwWDMz89fu3btypUrNBotNrSxsLDQ09OTnp5uMBiW\nuhAzmUyj0ejz+Zbj3ryI9PR0MKEc2zmNRCJms7m+vn7Fwx8CgeDRRx+dm5uzWq1kMlkgENzR\niWEQyC0k6cLuxz3GzIc/+PUP7kcQZOiHHURmy3/tkGARyX89kdf6+1cQ5CbCzj755x+f8P34\nN3u+ehAKOwjkdiEYDA4PD8/Nzfn9fi6XK5VKORxO4lPMZvN7770nl8tBm1cwGOzt7d20aVNj\nY2PiE8vKygoKChYWFoBBcWLpE4NIJDY0NMTHJCwsLJw+fXpubk4qlYLCktvtHhkZodPpTzzx\nRLKTDEJe7wc7d86eO4cgSNnzz9OefFJz5IjBYAAiEgSRgU3kBBfB4/FgCvVvrhwK4fF4pVLp\n9/vjEz74fL7JZBodHcVisUv7FIE/y8q+6vLy8uHh4eHhYS6XC4JfDQZDenr6Tf8rE4PBYEQi\nEcxdgEBWSdKF3Yw/JG34xKrgf3oWuGU/BY211BxqyDuc+NxIwPCjl/+w/etvSiirsq2HQCBr\niMVi+eCDD0ZHR71eL5hb7O7u3rZtW1lZWYKzzp49Ozg4mJOTA/rewuHwxMTE2bNnQRp94jsS\nicSbvuamqFQqnU5XUFAQ2y6kUqmpqalqtXp+fv66Vbq1IujxXHnuuYUrV5BP/eoCwaBOr+/v\n7x8YGABNeyBcIXFFMC8vTy6X+/3+2MxvMBh0uVy5ubkqlWpp7Y1CoTgcDqlUOjg4GH9WOBy2\n2WwVFRUrs4ij0+mPPvqoQCCQy+U2mw2YDLe2tsb2piORyNzcnN1uB7W3pdliEAgkeSRd2DUx\niPJjg8g/l/ptp99e8Nz/1ic9E31HtXjKTSzs//KTl21VLz5bzYuGrdd9wdDQUHwejt/vT5BQ\nvnqAv7zJZIIT+IBAILCwsHCrV3G7EAgEotHo0t6ju4+jR49euXJFLBaD4kowGFQqlWCmIVa3\nA1OosR9Pm802MDAANgSB4zGCIEKhUKFQ9PX1rY8DrVardbvdfr/f7/fHDkajUZPJpNFoVhl6\nloCQ13vu0CGg6iSHDlV8//vGhQUEQVpaWgQCwezsrMVi4XA4WVlZeXl5FoslwaUyMzNTU1Ov\nXbvG4/EoFIrX6zWZTFlZWdnZ2SqVCswuxL8ebGtmZ2enpqb29/enpKSArFggZPPy8lbzhtnc\n3FxaWupwOCgUCovFwmKx4Grz8/OdnZ2Tk5MejwePxwuFwvr6+tiUCSDZ79V3Fj6fL/6H5R4n\nGo2GQqFAIHCrF7IexL8XrSFJF3bfeyq/+dWnH3r2Gq77f1Ec58etqSHf5K//8z+/1Dkn2PSf\nCU40dv3idwrhG2+1JXgNmUyO+WEGAgEURZM6QgWEHQ6Hg8IOEAwG4cxajGAwmOzvwNsBs9k8\nNTXF4/Fiw49EIjEvL29yclKj0cQsM4DGjT0Nv98fCASoVGr83h8Gg0FRFGSDrsPKY31m8WsI\nhUJEIpFKpSZpDSGv9/yTT85duoQgSP6TTza/8kr8tIRUKk08BbIIgUCwb9++zs5OlUrlcrnA\ndnNTUxNQaQqFwuVygYIogiAejycQCBQWFgqFwj179ly6dEmtVlssFgKBUFFR0dTUlJ2dvcqv\njsvlcrnc+CN2u/3YsWNKpVIgEKSnp/v9/qmpKVDVi08Zhm8d8YAfBPhAAJFIJBKJ3CNPI0la\nIunPrv4n576r2/7j370WRMlPv3K5lIp36Y5+4Ttv0NJb/u/d3QlOXLg0FHAantmzK3bk2POP\nn6aWH3n7B7EjEokk9rFOpwsGgzdt9FkN4XDY4XCAv02Td5c7CLPZzGazocwFgFJuUr8Dbwds\nNlskEklJSYnvbadSqeBPrNiXD35YYiZkoVCIwWCgKBp/VjQaJRKJPB5vfR5aSUlJd3e3xWKJ\nhV9FIhGLxVJcXFxYWLjKquHc3Nz09LTb7WYwGDk5OeArCno87z/6qKGjA0GQ7Mcff/C3v8Ws\n+q2Dw+EUFBRYrVan00mn01ksFtCp7e3tRqNxcHAQ5Lp6vV6/319TU7N582YWi8XhcAoLC00m\nE3Ah5vP5q//FaTKZlEoluF16enpOTg6CICMjIzqdrqKiIrYvLBKJhoaG5HJ5Y2Nj7L3CZDLd\n9T8pywd0SULHPkAoFAJ+kLd6IetBkjYrki7sMDjuv7zT+y2PyY3lMIkYBEFI7B0f/KWhbUsD\nM6FHce6T33rlkU9K09GI4ytf/W7Tt3+0L4Wb4BQI5A4C+PWDvWwul5uZmXlHSGQCgYDH4xdt\nG4FidoI3KR6Pl5aW1t/fHx8kbzAY2Gz2cjJV14SsrKz6+vqLFy8ODw+z2exwOGy1WtPT09vb\n21fz9hqJRC5evNjZ2Tk3NwcqDWKxeOPGjRUlJTFnE+mzzxZ885trlQML/n5YJIyoVOpjjz2W\nk5MzPDzscrl4PF5JScmGDRtiORYYDCYlJWWt4rk6OjqOHTsGQnIZDIZIJKqtrd22bZvBYIhE\nIvHdfiiK8vn8+fl5u91+j/y2hkBuLetU7cRReMy/fly8c/vNTyEJMvM+jeQBPXaszJwcaFAM\nuStwOBxnzpwB9ZVoNMpkMsvKyrZu3Zo4GuF2QCAQCASCsbGxmMcbgiBzc3NsNjvBfAMGg2lr\nazObzUBU4XA4u90OQtDjBzmTzbZt21JTU3t6esxmMxaLlUqlTU1Nq1SW/f39J0+ejEajxcXF\nOBzO7/erVKrjR4/KX3opNi3R/rOfaXW6NfoibghwVN64caPX613qb5IAg8EwOTkJinlisRjU\n3hJw7Nix1157TaPRRCIRFEXpdLper5+bm2MymeDIotejKBqNRpdO5kIgkGRwT2xjQyC3FZFI\n5Pjx4x0dHQKBID8/H0XRhYWFCxcuBAKBxx9/PNm+G6sEj8dv3LjRarXKZDIej4fH40F4V3Nz\nc2LD3ry8vEOHDnV2dk5NTYVCIaFQWFNTU1lZuZqvNxKJKBQKnU4HalSFhYWJK1JYLLaysrKy\nstLlcuHx+KV5sp+VaDQ6ODjocrliE8FEIrEwN9f4H/+xoNMhn87ABpd4lCQPFEWXk/cKiEaj\nly9f7ujo0Ov1oOzK4/Hq6uq2b99+o73a4eHh3//+93K5nEAggEqn2Wy22+02m+3ChQsbNmyI\nRCKhUCj+dIvFIpFIYs1/EAgkqdwZwg7Fsj/88MNbvQoIZG3QarVyuVwoFMZ8cVNTUzEYjEKh\n0Gg0N62X3HJKS0vJZPKlS5f0en0oFBKLxXV1dTU1NTeVaCKRaN++fYFAIBAIrNjJNobH4zl8\n+PCJEycMBkMoFKJQKEVFRQcOHFiOm9rq7w7w+/0mkylWZ41EImgo5H39dUqcqlurHdgY0WjU\nbrc7HA7QY7eaHXylUnn69GmPxwMyyqLRqFarPX/+PIfDue5jjEaj3d3dU1NTKIqyWCzQWEmj\n0ex2u8ViGRkZeeyxxzIzM0dHR3Nzc6lUaigUmpmZIRKJ1dXV90g7PARyy4E/aRDIegN62ONH\nfxAE4XK5Y2NjZrP59hd2CILk5eXl5eU5HI5AIMBmsz/TOFGs0rNKjh49+tZbb/n9fiaTicPh\nPB5PV1eX2WxOTU1d/bznUkKhkEwmm56etlqtfD4/Pz+/oKAAePz6/X6lUjk3Nxdwu4u7u2kG\nA4IghNbWZKi6ubm5ixcvKpVKEBqRm5vb1ta2YlNfhUKxsLAQSxtDUTQjI2N0dFQmk9XX1y9V\n6k6nc35+HkXRSCQScyTAYrEYDCYajYLZsp07d545c2Zqasrr9eLx+JSUlIaGhrq6utV81RAI\nZPlAYQeBrDfA1BfsfMUA/7wj5idi3MLNNZ/Pd+zYMafTWVBQABQGl8u12Wzj4+Nnzpx57rnn\nEAQJBAImk8nj8cSnvq4Mj8fz3nvvyWQyj8dDJBJ9Pl93d3d9ff3999/P5/OPHTuGwWDwCFIz\nPEwzmxEEmU1L2/a1r625qltYWDh8+LBSqeTz+QwGw+v1Xr582WAwPPHEEwKB4ObnL8FoNC7t\nxmMwGFar1ev1Lg31ikaj0WiUQCCgKBq/3wq8x2g0GoFAKCwsFIvFKpXKbrdTKJS0tLSVrQ0C\ngawMKOwgkPWGz+ezWCyTyRSflGoymVgsFp/Pv4ULu4PQ6XSgWz9WN0IQhMViaTSayclJBEHk\ncnlHR4dOpwP+eUVFRe3t7cuMI1vK1atXe3p6RCIRGPUAW5adnZ1isRiDwQQCATyCNKlULLMZ\nQRB1SooiL+/+JOw8Xrt2TalUFhUVge5ANpvN5/NHRkZ6enoeeuihFVyQRCJdN6MMh8Ndd+eU\nTqdzuVwajUYmk4ElNUg5c7lcwFEFaEECCDefAAAgAElEQVQKhVJaWrqC9UAgkNWTFGF39OjR\nZb5y586dyVgABHI7k5aWVlZWdv78+VAoBJQc2JxtbW1dN++POx3gYnrdrr5wOCyXy48cOWI0\nGkUiEZPJdDqd58+fN5lMhw4dWkF3XTgcHhkZIRKJMTNesGU5ODg4NjZmtVpLCwtFJ0/SFhYQ\nBDFkZgY3b86ORJKRrAByw+JnPvB4PI1GU6lU0Wh0BSVJsVjc29vr8Xhi8xahUMhms1VVVV13\nsgSDwVRXVw8MDFgsFp/Ph6Ko1+v1+XxsNru4uHjTpk3xOhsCgdwSkiLsdu3adfMXIQjy6fYT\nBHJPgaLo9u3byWRyX1+fVquNRqMsFmv79u1tbW131lbsGuL1evv7+7VarcvlEggEJSUlifvk\nUlNTuVyuWq0GcyfgoMfjwWAw6enpV69enZ+fLysrA8+TwWCwWKyxsTGZTNbU1LSCtbnd7qWj\npiQSyWg0eh2OnIsXcQYDgiChmhrR/v35dPrExITD4fisN0pMNBr1+/1LC2k4HC4YDMbnfCyf\nqqoqhUIBPGhoNJrP51tYWMjJyWloaLjRKTU1NT6fD0GQkZERu92OwWBSU1OlUunmzZuXM7YC\ngUCSTVKE3YULF2IfR4LGlw8+1esVPfMPz2+ql7KwvonRq2/85GeGjL0Xjr+SjLtDILc/FApl\nx44d1dXVJpMpGo3yeLx7uQ/JZDK99957CoUCWPD39fX19fVt3Lixvb0dvMDj8czPz3u9Xjab\nLRAIMBgMjUbbtGnT7OysRqMBxng+n89kMmVmZtbV1Z07d47H48WrZDChqdfrV7A8IpFIJBLt\ndvui44FAgE2jBX7+8+jUFIIg+JYWxsGDoK8OLHWFj+MGoCiampoKNprjcTgchYWFK5s5ZTAY\n+/fvF4lEo6OjoH2wubm5tbU1sSVha2trcXFxf3//+Ph4NBrNzs7Ozc0tLCy8zZ16IJB7hKQI\nu40bN8Y+Pv+CtNcj6Zju3sD5pLC/5f5Hnn/x6bbUyr3fPqT4zdZkLAACuSNYwySAO5rz58/L\nZLLc3FwQkxCNRlUq1cWLF7OysrKysvr7+y9dumQ0GkG3XHFxcXt7e0pKyv79+4F3mtlsBsMo\nhYWFe/bsKSgoOHPmzFKRgcFglvaTLSIYDMpkspmZGavVClwGJRIJHo/Pz8+fnJwExr/glRaL\nhYCi3tdfjyqVCIJE6urIn6o6g8FAJpOTYbxcUlIyMjIyOTmZnZ2NxWIjkcjU1BSDwYi56K0A\nDoezc+fO++67DxgUg+S3m57F4/G2bt26dSt8A4dAbjuSPjzxtT9O5D5xIabqPrkrpeinz+Y3\nvflV5DdDyV4ABAJJEj6fz+/3L1MK3Ai73a5UKrlcbiz8CkXRnJycoaEhlUplsVg++OADp9Mp\nEokIBILdbr9w4YLFYjl06BCHw3nppZdaWloUCoXZbM7NzS0rK8vPzw+Hw0wmc3p6OjU1NXaX\nUCgUDocTz6a4XK4///nPQ0NDHo+HQCD09fV1d3c3NDRs3769oaFhenp6bGyMTCaTSCSXy4UE\ng1nnz9vlcgRBSG1t6oqKmeFhEonk9XppNNqGDRvKy8tX/ExuRGlpqcViuXz58sjICDgiFAob\nGhrAvcLh8NDQkFKpXFhY4PF4OTk5lZWVy2x6o9Foa+XtB4FAbi1JF3aT3lAa4Xr1eQwS9muT\nfXcIBJIMNBrN5cuXtVptKBRisVh1dXVVVVUr2w10uVw+n29RBxuot9nt9vHxcbvdLpVKwXEK\nhcJgMMbHx0dGRurr68lkcnNzc3Nzc/y5OByuqqpqenp6eno6PT0di8V6vd7JycmMjIzi4uIE\nK+ns7Ozt7U1LSwMxrNFodGZm5vLly2KxWCqVHjp06OrVqwqFwufzCTgcwh/+4JDLEQQpe/75\nttde6x8YUKlUZrNZIBAUFBSUlpZ+Jm+/ZYKiaFtbW35+vlqtdjqddDo9OzsbzFYHAoH333//\n2rVrbrebTCYrFIre3t6xsbG9e/cuP4gCAoHcBSRd2D3Kp/zP77+u+cnZLOJf3+bC/plv/WaC\nkvJ0su8OgUDWHLlc/v777+t0Og6Hg8PhJiYmNBqNwWB4+OGHV1C6I5FIBALB7/cvOg6s0Uwm\n06IyG5VKDQQCiWdOGxoaXC5XT0/P6OhoJBIhEAi5ubmbN29OYOQbDAblcjmJRAKqDkEQFEUz\nMzMHBgYmJiakUimdTs/IyIhEIkadzvfLXzoGBpC4bIn6+vr6+vrP+rWvDJFItPQLGRgY6O7u\nZrPZsWA3i8XS19cnFovb2trWZ2EQCOR2IOnC7ttvHPjVzl+VS3d8718+Xy8tZKIO5Wj369/7\nlzNW33NvfSPZd4dAIGtLKBS6ePGiXq8vKysDdTWRSKTVant7e0tKShLHxV4XDocjFou7urr4\nfH5s31Cn07HZ7LS0NIVCcV2xGA6HE1wTh8Pt2LGjtLRUq9UCg2KJRBLb6r0uHo/H7XYvteQl\nkUjA2uPDDz8cGBiwm0ypJ06QtVoEQTj337/59dfX3IV4ZYyPjwcCgfgRHA6HMz8/PzIysnHj\nxnt22hoCuQdJurATP/zmuVdxj37tzS8/eTp2EEvgf+HVs794GFp2QSB3GHNzc3q9Pi0tLX46\nIS0tTSaTzc7OrkDYoSja3t5uMplGR0fpdDoej3c4HEQisampqaampre3V6vVxo+Y+P1+DAYT\ns5RLQHp6eoLpzkUQiUQCgeB2uxcdB7G23d3dV65c4TIYKZcvh7VaBEF8FRXqigrF2FhJScmy\nv9YkYrFYYoMdMSgUitvtDgQC1zWlg0AgdyXrkTzR/qVf6J/555Mfnx5R6YMYUlpe6eb7t4pp\nMPQCcofh8/ksFgsGg+FwOGuSdnonEggEgsHgojAxUBBaup26TMRi8ZNPPnnlyhW1Wu33+8Vi\ncXV1dXl5OeiWA54maWlpOBzO6XSq1erc3Nw1l1MkEkkikZw6dQpksIKDZrOZSCRmZmb29vZi\nIxHau++Gx8YQBMG3tNAPHJANDY2Pj98mwo7JZKrV6kUHfT6fQCC4Z79XIZB7k3VSV+qe7r6B\n0RmjpfU/3ngMf6VbYxFLocsD5I4hEAj09vZ2d3fbbDYEQbhcblNTU2VlZTIa5G9z6HQ6qAMx\nmczYwWAwiMViE+91JobP5+/cuTMSifj9/vjKU1NTUyAQ6OrqGh8fD4fDFAqlrKxs8+bNy6nY\nfVaampq0Wu3Y2BiVSiUSiS6XC0GQ6upqiURy7uRJ/scfhz/1qwPOJiQSaWFhYc2XsTLy8/Nl\nMpnVao355zkcDr/fX1xcDPdhIZB7inUQdtHXn25+8a0r4B+Ul197wPVae+XHrc/+7MybL+Lg\nGw7kTuDUqVPnzp0DtbpoNDo1NWUwGFwu1z3Yls7j8SQSSUdHB51OB0ouFAoplUqRSCSRSFZ5\ncQwGs2g/EYfDbdmyRSqV6vV6n8/HYrFyc3NjFbW1JSUl5Yknnrh69er4+LjP5xMKheXl5TU1\nNWGfD/9//4f+rapDECQYDN4+A6dVVVUqlWpgYECv11OpVK/XGw6HKyoqNmzYcKuXBoFA1pWk\nCzvVH3a/+NaV+1589ZWX9pVL0hAEYUt+8uPnzd9884sPV953/POFyV4ABLJKtFptX18flUrN\nyMgAR/h8/uTk5NWrV8vLy9c8YOA2B0XRLVu2OJ1OhUIRCASAM3B6evq2bduSZ7acmpoab0qX\nPNhs9v333799+3av1wsGKYIez4d796KTkwiCYBobY6rO4XBgMJjEuWfrCZlM3r9/f15e3ujo\nqNVqzczMLCoqqqmpuX2kJwQCWR+SLux++JXTnKJvnPn5l/56S0rhN97oDFzh/cd3f4B8/g/J\nXgAEskr0er3FYiks/Js/QlJTU3U6nV6vv+uFXTQaXZRDyuPx/u7v/m5wcNBgMPj9fh6PV1pa\nejdFaGAwmJiqe//hh2fOnkUQBG1oUJWXM6engUGxx+Opqqqqqqq61Yv9K0QisbGxsbGxMRgM\nLtOXGAKB3H0kXdgdMXmL/unA0uOPPJnzvW98lOy7QyCrB4QWLGqnw+Fw4XD4phFVdzTz8/Pd\n3d1TU1OhUEgoFFZVVRUWFoKGLSKReNfv8cWrurLnn6/8wQ8ud3YqlUq/3y8QCMrLy+vr65NU\nDwMZEiqVymQy8Xi8vLy8z+R4DFUdBHIvk3y7EyLWOeFYetw6ascSb2gWCoHcPrBYLAqF4nA4\n4scF7HY7lUplsVi3cGFJZXJy8r333puenqZSqVgsVq1WKxSKtra2zZs33+qlrQE6nQ5Y3DGZ\nzLy8vEVDvsgSVQdciB955BG/3+92uxkMxspiNpaD3+9///33+/v7XS4XiUQaGhrq6emprq7e\ntWsXdC2BQCA3JenC7lsbUp76vye7/m20nvfXfmeP/tzT76h5Vb9K9t0hkNWTk5OTk5MzPDwc\nS6m32Ww6na6+vn75Nml3FqFQ6OzZs9PT01KpFCiYaDSqVqs7OzsLCgpivYZ3IqFQ6Ny5c93d\n3fPz8yCUIisra9OmTWVlZbHXXFfVgU8RicRkq6u+vr6uri5QqANHjEZjV1dXRkZGY2NjUm8N\ngUDuApIu7Ha/86t/ydy5Mbviqc8dQBBk9PBvf2Ab+s3rf9BFUg+/+2iy7w6BrB4SifTggw+i\nKDo+Pg6s2igUSm1t7f3333+32p3Mzc1ptVpgHQeOoCialZU1MjKi0WjuaGHX09Nz6tQpAoFQ\nXFyMw+G8Xq9KpfJ4PBwOB8j0BKpufVAoFJFIJL5nMSUlxWg0jo2NrUbYhcNho9HocDioVGpK\nSgo0t4NA7laSLuzI/PsHZB++8Lmv/Pcr30UQ5MJ3vnIRxZa0P/r+z19/MHVxeg8EcnuSkZHx\n1FNPjY6Oms1mDAbD5/OLi4vv4k4mr9cbCAQWbTRjsdhoNOr1em/VqlZPOBzu7+8PhUI5OTlO\npzMQCJDJ5MLCwpGREblcnp6efstVXSQSsdlsS1v3KBSKxWKJRCLxgR/LR6vVnj9/fmJiwuv1\nkkikjIyMtra2/Pz8tVgyBAK5vVgPg2KGZMcfz+34zcLUqEofwpLTJSXpLNgpArnDIJFI1dXV\nt3oV6wRw6PV4PPGew6FQCIvFLk1TvYNwOp1WqzUYDHZ2dtpstlAoRCAQhEJhNBqdn5+/5aoO\n+XQgV6fTLTru9/upVOrKVJ3RaHznnXdUKlVqaiqbzfZ6vUNDQyaT6fHHH7997FogEMhasZK3\nic9EQ0PD/9O6EAQh87Nr6pvqa6uAqpu78o8tmw4l++4QCGQFCIXCrKws4AkMjkQikcnJSYFA\nkJOTc2vXFg+YHj1+/PiRI0fOnTun1+sTvx6LxZrN5tHRUYPBQCQSmUwmiqITExNKpTLgdt9y\nVQcoKCgIhUIOx19nzhwORygUWmS4s3wGBwdVKlVxcbFAIKBSqTweTyqVzs7Odnd3r9GSIRDI\nbUSyKnaOqUlDIIwgSFdXV45CMe5eNHQWHTnWceWSJkl3h0AgqwGDwQAXYqVSicPhsFisx+NJ\nTU1tb29fH6Pg5eByuT744IOhoSGXy4XBYCKRiEgkam9vb2pqutEpVCrV4XCYzeaysjJQ/SIS\niTgcTjMxYfvpT61KJXKrVR2CIHV1dWq1emhoCIfDkclkr9cbCoUqKytra2tXdsHp6WkikRjf\nVIfBYNhs9szMTCAQgM12EMhdRrKE3XvbNzyjtICP/7i17o/Xew0j68Uk3R0CgawS0FbY19c3\nOzvr9XpFIlFFRUVmZuatXtdfuXTpUldXl0gkAtOj4XB4cnLy7NmzaWlpWVlZ1z3F5XIxmUwe\nj6fX61ksFg6H8/l8bptti1YbtdmQ20DVIQhCo9EOHDiQl5cnl8sdDkdaWlpxcXFdXd2KPfNC\nodDSuFgURSORSCQSWfV6IRDI7UWyhF3j9195w+ZDEOSFF17Y+IOfPs4nL3oBBk9v2LM3SXeH\nQCCrh8lk3nfffbd6FdfH6/WOjIyAjUVwBIvFSiQSmUymVCpvJOwikQiXyy0uLrbb7Var1ev1\nkrDYtqkpym2j6gAUCqWtra2trc3r9S4Kz10BIpFoaGho0eCF3W5PXuouBAK5hSRL2BXs/7sC\nBEEQ5PDhw7ueefZzIlqSbgSBQO5BnE6n2+2On+1AEASDwWCxWKvVeqOz6HQ6m81eWFhobGx0\nuVwBt5v09tuITocgCOf++28TVRfP6lUdgiBSqXRoaEihUAAlFwwGp6amGAxGZWXl6i8OgUBu\nN5I+FXv+/Plk3wICgdxrEAgEHA4XCAQWHQ+HwwmqUFgstqqqSqPRzMzMZAiF+N/9LjwxgSBI\npK5u25tv3m6qbq3Izc194IEHzp8/r1arA4EADodLTU1tbm6uqKi41UuDQCBrz3rYnZiuffDN\nH/8ieOi/39qViSDImW2VL+OkX/7XVx6t46/D3SEQyN0Hi8XKyMjo7u4WCoUxF2Wz2UylUhP7\nJ9fV1Xk8nqsdHdZXXiHNziIIgmls3PHmm2l3aYgIoKqqKicnZ2pqym630+l0sVjM58O3Xwjk\n7iTpws4+8av8+s/bUeYzz33S3sGpkky/evjxUx+Zh6Y+X8RO9gIgEMhdSWtr69zc3MjICJfL\nJRAIDocjEAjU1NRIpdIEZ2Gx2NaGBsP3vjc3O4sgSNqePQ/97ne0v93SvSthsVhw7xUCuRdI\nuo/dbx75lptc2TGj+/X2T/6Mrvq3P6lnrmyg+F7eB7NiIRDICsnOzj548GBzczOFQolEIkKh\n8JFHHtmzZ09i/w7gQjx36RKCIGXPP//4u+/eC6oOAoHcOyS9YvfTSXvesz9vEv5NCzCJX/va\nCwX1r/4Xgnw92QuAQCB3K+np6QcOHPB4PF6vl8lkxvZkb8TtkC0BgUAgSSXpwi4cjRKY1/kD\nGkvBIgi0UIJAIKuFQqEsx+MNqjoIBHIvkPSt2C9mMcbf/M6sPxx/MBIwfPfnY/T0zyX77hAI\nBIJAVQeBQO4Zkl6xe+G9l39U8dWSwk1f+aenm8ryKJjglLz7f1759zPm0HePfzHZd4dAIBCo\n6iAQyL1D0oUdR/rl0Y+w+z737e/+Y0fsIIlT+L233325Fs7bQyCQ5AJVHQQCuadYDx+7rB3/\n2Dv9wkjXxYGxaU8Yl5pT0raxhoGF760QCCS5QFUHgUDuNdZD2CEIgqAEacMWacM63Q0CgUCg\nqoNAIPcgSRF2lZWVKIbYf60LfJzglQMDA8lYAAQCuceBqg4CgdybJEXY0Wg0FEMEH7NYrGTc\nAgKBQG4EVHUQCOSeJSnC7tKlS7GPz58/n4xbQCAQyHWBqg4CgdzLJEXYHT16dJmv3LlzZzIW\nAIFA7k2gqoNAIPc4SRF2u3btWuYro9FoMhYAgUDuQaCqg0AgkKQIuwsXLsQ+jgSNLx98qtcr\neuYfnt9UL2VhfROjV9/4yc8MGXsvHH8lGXeHQCD3IFDVQSAQCJIkYbdx48bYx+dfkPZ6JB3T\n3Rs4n4xTbLn/kedffLottXLvtw8pfrM1GQuAQCD3FFDVQSAQCCDpWbFf++NE7hO/jKk6AI5S\n9NNn81XvfDXZd4dAIHc9UNVBIBBIjKQLu0lvCEO43l0wSNivTfbdIRDI3Q1UdRAIBBJP0oXd\no3zK5O+/rvGH4w+G/TPf+s0EJeWxZN8dAoHcxUBVB4FAIItIurD79hsH/LaL5dIdr/7v+10D\nCsVg99E/vHZ/adkZq+/xX34j2XeHQCB3K1DVQSAQyFKSnhUrfvjNc6/iHv3am19+8nTsIJbA\n/8KrZ3/xsDjZd4dAIHclUNVBIBDIdUm6sEMQpP1Lv9A/888nPz49otIHMaS0vNLN928V09bj\n1hAI5O4DqjoIBAK5EeukrvD0rAcff+7B9bkZBAK5e4GqDgKBQBKwTsJu/Ow7b5+8OmO0tP7H\nG4/hr3TryzZKU9bn1hAI5K4BqjoIBAJJzDoIu+jrTze/+NYV8A/Ky6894HqtvfLj1md/dubN\nF3HwPRkCgSwPqOogEAjkpiR9Klb1h90vvnXlvhdflU3owBG25Cc/fr7h4q+/+PAbY8m+OwQC\nuTuAqg4CgUCWQ9KF3Q+/cppT9I0zP/9SWZ4IHMFRCr/xRuf3SrkXv/uDZN8dAoHcBUBVB4FA\nIMsk6cLuiMmb+9SBpccfeTLHZ/7/27vTADnqOuHj/54ryZBjJglJQMJsSELCEQl4bNSwkUAM\n17KgcskSQIyKrjwoUXZFAblUVkBQAiwK7AoKuypRXBA5DRqUc8EDUARMyEEyyeSao6ev58XE\nYUhCzqmp6urP59VMddH1ozNd853q6uq7o946UO5UHcC2izzs9uxXve7Pazdd3vKHNdX9do96\n60BZU3UA2yXysPvi34946bZZv2nu6LmwbclDZ9z58vADz4t660D5UnUA2yvysPvgnf+xZ2bh\ntDGTPzHn4hDCH+64+ZLPn77v+JkLi7t9639OiHrrQJlSdQA7IPKwG7Drkc88+9MPvavqO1dd\nFEJ45EvnXnjlbYOmHH/XM899aLddot46lK/Ozs6Ojo6tr5dGqg5gx0R9HbtiNpsbMO6I7z90\nxHdXvPKHvyzJVw/YY/x+ezT0i3i7UMZeeumlxx57bMmSJSGEkSNHTpkyZcKECZmKKRtVB7DD\nog27UmFdQ33j33//z4+cOHbArmPeueuYSDcHKfDEE0/cc889y5cvb2hoCCEsWrTo5Zdf/sAH\nPjB16tS4R+sLqg5gZ0T7Umymesi5+wx9+eYnIt0KpMa6devmz5/f0tLy9re/vampqampadKk\nSW1tbfPnz29ubo57usipOoCdFPk5dl9+9J63L/rMp6/9ycpsIeptQblbtGjRsmXLRo8e3f3C\nayaTaWpqWr58+cKFC+OdLWqqDmDnRf5ZsUefcH5x5J7Xn3Pc9Z/tP3K3XfvXviklX3nllagH\ngDKSzWZzuVy/fm86CbWuri6Xy6X7jRSqDqBXRB52/fv3D2H3o45yLWLYuoEDB/bv37+1tbWu\nrq57YWtr64ABAwYNGhTjYJFSdQC9JfKwu/tunxsG22rPPfdsamr63e9+V19f33XcrrOz8+WX\nXx43btyYMel875GqA+hFUYVdqbDuF3fc9uBTf1yfrx0/+f1nnX5M/8hP54Oy169fv5kzZ3Z0\ndPzpT38KIWQymWKx2NTUNHPmzIEDB8Y9Xe9TdQC9K5Kwy3e8dPyB75r3wuq/Lbj66zee8tDD\nt+5bH/kBQih3e+2110c/+tGnn3566dKlhUJh9913nzx58rBhw+Keq/epOoBeF0lpPfzJo+a9\nsHrsB8669FPHDc+s+ukNF3zr3tuPPvWDL//og1FsDlJmyJAhhxxySNxTREvVAUQhkrC7ZN5f\nBww7+tl7r9ulKhNCOOzoY14bOexnP/9SCMIOUHUAUYnkxLfH13XufuicrqoLIYSqAZ87cnS+\n/YUotgWUF1UHEJ1Iwi5bLNUNreu5pG5oXalUimJbQBlRdQCR8lZVoI+oOoCoCTugL6g6gD4Q\n1fVHVj37gyuvXND97cKnmkMIV1555UarnXvuuRENACSHqgPoG1GF3euPfWvOYxsvnDNnzkZL\nhB2knqoD6DORhN3PfvazKO4WKDuqDqAvRRJ2Rx11VBR3C5QXVQfQx7x5AohEvr1d1QH0MR/e\nCvS+XFvb/R/5yJJf/jKoOoA+lJ6wK5VKpVIpn89Ht4lCoRBCyOfzLrbcpVgs5vP5jF/YIYQQ\nisViJpOJ9CewXOTa2n5y7LFdVbf/xz42/dvfzhcKcQ8Vp+5dR1WVF0lC+NuuI+4pkqJUKnlA\nuuXz+cp5NCJqifSEXdePQmtra3Sb6Po3aGtrs3fuksvlWltbhV2Xrj1RpD+BZSHf3n7fSSd1\nVd3E009/z7//e2tbW9xDxawr7Nra2jxZukS9ry4vXQcLPCBdisViZ2dnhTwaEfVresKuurq6\ntrZ2yJAh0W2iUCi0tLQMHjy4uro6uq2UkXw+P2TIEL+ruuRyuUwmE+lPYPLl2tru+tCHuqpu\nwmmnHX3zzV6BDSHkcrk1a9YMHjzY34RdcrlchT9Tespms1H/8iojXa8CVcijUVtbG8Xd2ssA\nvaPne2AnzZ499aqrVB1AHxN2QC/Y6Momh82dq+oA+p6wA3aW69UBJISwA3aKqgNIDmEH7DhV\nB5Aowg7YQaoOIGmEHbAjVB1AAgk7YLupOoBkEnbA9lF1AIkl7IDtoOoAkkzYAdtK1QEknLAD\ntomqA0g+YQdsnaoDKAvCDtgKVQdQLoQdsCWqDqCMCDvgLak6gPIi7IDNU3UAZUfYAZuh6gDK\nkbADNqbqAMqUsAPeRNUBlC9hB7xB1QGUNWEHbKDqAMqdsANCUHUAqSDsAFUHkBLCDiqdqgNI\nDWEHFU3VAaSJsIPKpeoAUkbYQYVSdQDpI+ygEqk6gFQSdlBxVB1AWgk7qCyqDiDFhB1UEFUH\nkG7CDiqFqgNIPWEHFUHVAVQCYQfpp+oAKoSwg5RTdQCVQ9hBmqk6gIoi7CC1VB1ApRF2kE6q\nDqACCTtIIVUHUJmEHaSNqgOoWMIOUkXVAVQyYQfpoeoAKpywg5RQdQAIO0gDVQdAEHaQAqoO\ngC7CDsqbqgOgm7CDMqbqAOhJ2EG5UnUAbETYQVlSdQBsSthB+VF1AGyWsIMyo+oAeCvCDsqJ\nqgNgC4QdlA1VB8CWCTsoD6oOgK0SdlAGVB0A20LYQdKpOgC2kbCDRFN1AGw7YQfJpeoA2C7C\nDhJK1QGwvYQdJJGqA2AHCDtIHFUHwI4RdpAsqg6AHSbsIEFUHQA7Q9hBUqg6AHaSsINEUHUA\n7DxhB/FTdQD0CmEHMVN1APQWYQdxUnUA9CJhB7FRdQD0LmEH8VB1APQ6YQcxUHUAREHYQV9T\ndQBERNhBn1J1AERH2EHfUXUARErYQR9RdQBETdhBX1B1APQBYQeRU3UA9A1hB9FSdQD0GWEH\nEVJ1APQlYQdRUXUA9DFhB5FQdfEO/MQAABkgSURBVAD0PWEHvU/VARCLmrgH2JJSvuWum268\nd8GzKzuqdhs9/phTPznzwFFxDwVboeoAiEuij9j94vI5t//y9WPOOPvrl5w3fWx27kWfnrdo\nfdxDwZaoOgBilNwjdoXsohueap52+Tf+cb/GEML4iZOWPn7ivLm/P/arU+IeDTYv395+14kn\nqjoA4pLcI3aFjlebxow5cq/Bf1uQOXBIv9xqR+xIqHx7+wOnnKLqAIhRco/Y1Q05+JvfPLj7\n29z6F25esr7pjAk911m7dm2pVOr6OpvNFovFbDYb3UjFYjGE0NnZWVWV3CDuS4VCIZvNZuRL\nCLm2tgdOOWXZo4+GEPY788xp11yT7eyMe6g4FYvFfD4f6fOxjOTz+RBCNpu16+jSteuIe4qk\nKBaLHpBuhUKhcnYdXVHR65Ibdj399cl7rr3m5txeR5x/+B49l//2t7/t/ucfMmRIqVRasmRJ\n1MMsW7Ys6k2UkdbW1rhHiF++vX3B7NkrFiwIIYw5+eSJX/zikqVL4x4qEdavd4j9DXYdPbW1\ntcU9QrKsW7cu7hESpEIejY6OjijuNulh19ny4s3fuvbeZ1ZN+/BZl31kev83HxyaMWNG99eL\nFy9eunTpmDFjohumUCgsXLhwzz33rK6ujm4rZWTlypVDhw6t8CN2Xe+W6Kq6vWfNOubWW70C\nG0IoFApr165tbGyMe5BEyOVyr732WlNTkyN2XZqbm4cPHx73FEmxfPny2tpaT5Yu+Xx+/fr1\nDQ0NcQ/SF1auXLl27dpev9tEh926vz547pxvV0864oqbZk0Y3j/ucWBjPd8Du/esWe+78kpV\nB0CMkht2pWLbZefN7Xfo2dd+8hC/Kkmgja5sctCll6o6AOKV3LBrW377H9tyZ0yqf+rJJ7sX\n1gwYN3m/ijhCS8Jter265pUr4x4KgEqX3LBb99KrIYRbvn5Zz4WDR3/xtutcx46YuQoxAMmU\n3LAbNfWyn06NewjYhKoDILG8RQu2g6oDIMmEHWwrVQdAwgk72CaqDoDkE3awdaoOgLIg7GAr\nVB0A5ULYwZaoOgDKiLCDt6TqACgvwg42T9UBUHaEHWyGqgOgHAk72JiqA6BMCTt4E1UHQPkS\ndvAGVQdAWRN2sIGqA6DcCTsIQdUBkArCDlQdACkh7Kh0qg6A1BB2VDRVB0CaCDsql6oDIGWE\nHRVK1QGQPsKOSqTqAEglYUfFUXUApJWwo7KoOgBSTNhRQVQdAOkm7KgUqg6A1BN2VARVB0Al\nEHakn6oDoEIIO1JO1QFQOYQdaabqAKgowo7UUnUAVBphRzqpOgAqkLAjhVQdAJVJ2JE2qg6A\niiXsSBVVB0AlE3akh6oDoMIJO1JC1QGAsCMNVB0ABGFHCqg6AOgi7Chvqg4Augk7ypiqA4Ce\nhB3lStUBwEaEHWVJ1QHApoQd5UfVAcBmCTvKjKoDgLci7Cgnqg4AtkDYUTZUHQBsmbCjPKg6\nANgqYUcZUHUAsC2EHUmn6gBgGwk7Ek3VAcC2E3Ykl6oDgO0i7EgoVQcA20vYkUSqDgB2gLAj\ncVQdAOwYYUeyqDoA2GHCjgRRdQCwM4QdSaHqAGAnCTsSQdUBwM4TdsRP1QFArxB2xEzVAUBv\nEXbESdUBQC8SdsRG1QFA7xJ2xEPVAUCvE3bEQNUBQBSEHX1N1QFARIQdfUrVAUB0hB19R9UB\nQKSEHX1E1QFA1IQdfUHVAUAfEHZETtUBQN8QdkRL1QFAnxF2REjVAUBfEnZERdUBQB8TdkRC\n1QFA3xN29D5VBwCxEHb0MlUHAHERdvQmVQcAMRJ29BpVBwDxEnb0DlUHALETdvQCVQcASSDs\n2FmqDgASQtixU1QdACSHsGPH5dvb5/3TP6k6AEiImrgHoFzl2toeOOWUpfPnB1UHAMmQnrDL\n5/OdnZ2rVq2KbhOlUimEsHr16kzFF0y+vf3+j3ykq+omnHbaOy+/fFVLS9xDxSybzYYQIv0J\nLCOlUimbzXY9ZSgWiyGElpYWu44u2WzWM6VbZ2dnPp/3ZOlSLBZzuVzXUyb1Ojs7o7jb9IRd\nTU1NXV3d0KFDo9tEoVBYu3ZtQ0NDdXV1dFtJvlxb210nnOBY3Uaam5szmUykP4FlpOvJ0tjY\nGPcgiZDL5datW9fY2FhV5eyXEEJobm72TOmWz+dra2s9Wbrk8/n169c3NDTEPUhfqKuri+Ju\n7WXYPj3fLbH3rFkzrr9e1QFAQgg7tsNG74F935VXqjoASA5hx7ZyZRMASDhhxzZRdQCQfMKO\nrVN1AFAWhB1boeoAoFwIO7ZE1QFAGRF2vCVVBwDlRdixeaoOAMqOsGMzVB0AlCNhx8ZUHQCU\nKWHHm6g6AChfwo43qDoAKGvCjg1UHQCUO2FHCKoOAFJB2KHqACAlhF2lU3UAkBrCrqKpOgBI\nE2FXuVQdAKSMsKtQqg4A0kfYVSJVBwCpJOwqjqoDgLQSdpVF1QFAigm7CqLqACDdhF2lUHUA\nkHrCriKoOgCoBMIu/VQdAFQIYZdyqg4AKoewSzNVBwAVRdillqoDgEoj7NJJ1QFABRJ2KaTq\nAKAyCbu0UXUAULGEXaqoOgCoZMIuPVQdAFQ4YZcSqg4AEHZpoOoAgCDsUkDVAQBdhF15U3UA\nQDdhV8ZUHQDQk7ArV6oOANiIsCtLqg4A2JSwKz+qDgDYLGFXZlQdAPBWhF05UXUAwBYIu7Kh\n6gCALRN25UHVAQBbJezKgKoDALaFsEs6VQcAbCNhl2iqDgDYdsIuuVQdALBdhF1CqToAYHsJ\nuyRSdQDADhB2iaPqAIAdI+ySRdUBADtM2CWIqgMAdoawSwpVBwDsJGGXCKoOANh5wi5+qg4A\n6BXCLmaqDgDoLcIuTqoOAOhFwi42qg4A6F3CLh6qDgDodcIuBqoOAIiCsOtrqg4AiIiw61Oq\nDgCIjrDrO6oOAIiUsOsjqg4AiJqw6wuqDgDoA8IucqoOAOgbwi5aqg4A6DPCLkKqDgDoS8Iu\nKqoOAOhjwi4Sqg4A6HvCrvepOgAgFsKul6k6ACAuwq43qToAIEbCrteoOgAgXsKud6g6ACB2\nwq4XqDoAIAmE3c5SdQBAQgi7naLqAIDkEHY7TtUBAIlSE/cAW1Z85I65d89/etG66on7v/v0\nz5yxV31SBlZ1AEDSJPqI3cs/+tLVdz425YOzLzxn1sC/PHj+Z28sxj1SF1UHACRQgsOu1HnV\nnc+PPfni4w97z37vOPj/XfEvrUvvu31xa9xjqToAIKGSG3bZNfMXdhRmzHhb17f9GqYeOLDu\nqUeWxTtVvr39J8ceq+oAgARKbth1tj4XQti3vrZ7yT71NaufWxPfRCHX1rZg9uxFDz0UVB0A\nkDxJeS/CporZ1hDCsJo30nN4bXV+fUfPdZ577rlcLtf9bTabXb58eUTz5NvbHzr11BULFoQQ\nxp966uSLL16+YkVE2yoXnZ2dKyr+QejW2dlZKpUKhULcgyRCqVTK5XI9n56VrFgshhBWrFiR\n8adgCCHifXXZ6ejo8GTpViqV8vl8Z2dn3IP0hWw2G8XdJjfsquoGhBBa8sWB1dVdS1bmCtUN\ndT3XGTBgQG3thkN6nZ2dmUympiaS/6N8e/vDs2Yte/TREMLes2ZNveoqx+pCCLlcLqIHvBzl\ncrnofgLLTlfjejS6dIVdTU2NsOti19FTVVWVXUe3YrFYLBYr5NGIaIeQ3MeudpdJIcx/sT0/\nut+GsPtze37I1Iae64wfP77768WLF+dyuaFDh/b6JLm2trtOOGHp/PkhhDEnn3zUd79bXRk/\nc1u1cuXKxsZGv6u6NDc3ZzKZKH4Cy1GhUFi7dm1jY2PcgyRCLpdbt25dY2NjVVVyz37pS83N\nzZ4p3fL5fG1trSdLl3w+v379+oaGhq2vWv7q6uq2vtL2S+5epn/DIbvXVd/3qw2H63Ot//f4\nus6DDhvVx2P0fA/spNmzD7r0UsfqAIBkSm7YhUzdnA9PfOnWix546sWlL//+5guurN/t0Fl7\nDOzLETa6sslhc+eqOgAgsRL9kuK4Ey/9VPabd1x9wcqOzNgDpl168ey+7NBNr1dXKCbkAskA\nAJuR6LALmeoZp50747QYtuwqxABA2UnwS7HxUXUAQDkSdhtTdQBAmRJ2b6LqAIDyJezeoOoA\ngLIm7DZQdQBAuRN2Iag6ACAVhJ2qAwBSotLDTtUBAKlR0WGn6gCANKncsFN1AEDKVGjYqToA\nIH0qMexUHQCQShUXdqoOAEirygo7VQcApFgFhZ2qAwDSrVLCTtUBAKlXEWGn6gCASpD+sFN1\nAECFSHnYqToAoHKkOexUHQBQUVIbdqoOAKg06Qw7VQcAVKAUhp2qAwAqU9rCTtUBABUrVWFX\nLBRUHQBQsdITdoVsduljj6k6AKBiZUqlUtwz9I4nfvjDxa2tbc8/3zhu3IgDD4xiE6VSqa2t\nrb6+PiMZQwghdHZ21tXVxT1FUmSz2Uwm4wHpUiqVcrmcR6NLsVhsb2+36+iWzWb79esX9xRJ\nYdfRU6lUyufztbW1cQ/SF1paWjo6OqZPn15fX9+Ld1vTi/cVs1KpZtiwwVOnFkJYunRpdNtZ\nu3ZtdHcOpJVdB9AH0hN2AxsbVy1ePHz//aPbRKFQWL58+YgRI6qrq6PbCmVqzZo1mUxm8ODB\ncQ9C4uTz+RUrVowcObKqKj1nv9BbVq9eXV1dPWjQoLgHIQZVVVW9fngyPS/F9oGOjo4HHnhg\nxowZXkRgU88++2xNTc1+++0X9yAkTmtr68MPP3z44YfX1KTnb2l6y9NPP11fXz9x4sS4ByEl\n/PkIAJASwg4AICW8FLsdus6xc6IMm7V69eqqqirn2LGprnPsRo0a5V2xbKqlpaWmpsY5dvQW\nYQcAkBKOPAEApISwA+gLHatb2opeIQGi5b3326j4yB1z757/9KJ11RP3f/fpnzljr3oPHRuU\n8i133XTjvQueXdlRtdvo8cec+smZB46KeyiSpWPlY2d+7Gv/cP33PzFql7hnIUFe+fUPb79n\nwR9fXDxkjwnHnXnOByYNjXsiyp4jdtvk5R996eo7H5vywdkXnjNr4F8ePP+zNxbjHonk+MXl\nc27/5evHnHH21y85b/rY7NyLPj1v0fq4hyJBSsX2uf96zbqCw3W8SfNTN59zxfeHvevIL112\nwcx9OuZe9LnfteXiHoqy57DTNih1XnXn82NP/sbxh40NIYy7InP8rCtuX3z6qW/zlzehkF10\nw1PN0y7/xj/u1xhCGD9x0tLHT5w39/fHfnVK3KORFM/cev4zQ94fXr8n7kFIlrlX3bPHkV85\n69hJIYR9J3zt1aUX/ubPaycdMCzuuShvjthtXXbN/IUdhRkz3tb1bb+GqQcOrHvqkWXxTkVC\nFDpebRoz5si9uq9ykjlwSL/cakfs2GDNSz++/OcdX77wQ3EPQrJ0rnvsyXWdhx8//m8Lqs65\n6JLZqo6d5ojd1nW2PhdC2Lf+jU9z26e+5ufPrQmnxDcTiVE35OBvfvPg7m9z61+4ecn6pjMm\nxDgSyVHsXHrZl28//Lwbx9f7gGnepHPtEyGEkX/43/Pu+NlflrWPbBp79KzPHDHZ6bnsLEfs\ntq6YbQ0hDKt547EaXludX98R30Qk1F+fvOdfz/pSbq8jzj98j7hnIRHuveLLqw/69MfeMTzu\nQUicQnZtCOGquY9OOf6syy79txkTMjdceJbTc9l5jthtXVXdgBBCS744sHrD39wrc4XqhrpY\nhyJZOltevPlb1977zKppHz7rso9M7+8DBghh+W+uu+X5UTfc+v64ByGJqmqqQwiHXHjhcRMb\nQwgT9jlg6YITnJ7LzhN2W1e7y6QQ5r/Ynh/db0PY/bk9P2RqQ7xTkRzr/vrguXO+XT3piCtu\nmjVheP+4xyEpVjz6XOe6pR/90LHdS/734yffv8sBP/zBJTFORULU1I8P4bFpTW98ktjf71Y/\nv3lJjCORDsJu6/o3HLJ73Q33/Wr5YUePDiHkWv/v8XWdHzzMmRCEEEKp2HbZeXP7HXr2tZ88\nxGE6eho764tXHbfh6hWl4tpz51z0vvMvO36Es+MJIYT+jTMba267/09rJna9YaJUeGRx26D9\nxsY9F2VP2G2DTN2cD0/8/K0XPbDbF/ZrzP30uivrdzt01h4D4x6LRGhbfvsf23JnTKp/6skn\nuxfWDBg3eT/HdCtd/5FN40Zu+LpUaAkhNDTttZcLFBNCCCFTPei8Y8eff9kFe/zLGZNG1j3z\n8/+av772C5+cGPdclD1ht03GnXjpp7LfvOPqC1Z2ZMYeMO3Si2d71wld1r30agjhlq9f1nPh\n4NFfvO06J8oAW7LvqV89K1z7o+9847ZsXdPYfc7+2pff29Av7qEoe5lSycXQAQDSwIEnAICU\nEHYAACkh7AAAUkLYAQCkhLADAEgJYQcAkBLCDgAgJYQdkGgPHNGU2aIfr2yPe0aApPDJE0Ci\nNX34E3P2b+n6uphbftU1/1U/4rhPzXrjIzXHD6iNaTSAxPHJE0DZyLU+UzfwoBGT7379maPj\nngUgibwUC6RHMb+6EPcMO6Z8JwcSRdgB5e2WCcMax16dXf34P79/34H9hq4vlL4wevDg0V/o\nuc7/feUdmUzm1ewb7bT+r/PPOWnmnrs29Ntl6MQDp3/lxnuKb3H/xVzzdf/60bePHdW/tnbw\nsNGHnnj2b5o7eq6w9Ne3nzDjncMG9a8fsuuUI075nydWdN/0+m//+5Qj3rNrw8C6XYbs/a7D\nLr71kS1Pvl2DAWzKOXZA2SvmV502+fCVB596+bVnD6jKbHX91iXzJu9zwsLM2045Y/a44dXP\nPvI/F33yqHkLbnnmP0/fdOVvHjl5zoPLDjnx48d/bPTahU/ecNN1hz26sGXxvNpMCCEs+9Wl\n499/YWn4u2Z94rwR1at+/N3vnPS+n6998ZUzxwxe8eQ39p56Xnu/cR857dN7DWp/9Cffu/CM\nQx79yyP3XzLtrSbfrsEANqMEUCY61z8dQhgx+e6eC2/ee2gmk5n5rae6l3x+j0GD9vh8z3We\nueigEMIrHfmuby/ab1ht/T4Lmtu7V7jrc5NDCJf+ZfVGW8y1vViVyex5xI+6lyz4/HuHDx9+\nx/K2UqlUKmYPa+w/YNjhz6/v7Lq1feUjQ2urRk35QalUPGFEfW39PvOXtnbdVMitOPfA4Zmq\n/vPXZN9q8m0fDGCzvBQLlL9Mv//6xORtXDff9odL/rhq4ln/+Z5h/bsXHnnBNSGEO6//08Z3\nXDWgLhNWP//jJxet61rynit+vWLFihN3HRBCWLf46gdaOt5xxTUTd9nwztz+Q6fNu/7bXz5z\neHvzj/97eduE2bccPKq+66aqmuHnf//0UrHjwvte2+zk2zUYwGYJO6Ds1Q2cPKJ2W/dmHavu\nLZRKv7vy3T0vhtevYVoIYc3v1my0cnW/0fd99dTSoh+8u6lhzNvfe8rHP3fjHfetym+4mMDa\nPz8cQnjf9JE9/5ODzzzrUx87rKPl5yGEvWaN6XnTwNGzQghLf7Fss5Nv12AAm+UcO6DsZap2\n2fIKpWKP6zpV1YUQJn3h5n+fvvtGq/UbspnDfv/whf9cfvq/zZv3s0fm/+rX99/6/Zuu/txn\np8z7/cMzhvUvZoshhLrMZs/q28yVpDKZmhBCKf/GTW+afDsHA9iUsANS6U0XD3n9yVXdX/cf\nemR15pz86gkzZ763e2G+/YUf/fTZUQfUb3QvufUvPv2H1cMOeMdJH59z0sfnhBCev/eSfY+8\n4P996Zk/Xv+ewXsfFML9v368OTQN7v5PHjrvrO+tbJz7tZkhfPeV218NB43ovmn9a98LIYw8\ndGTYnO0aDGCzvBQLpE19dVXHqv9tzm24TkjHyt986qHF3bfW9B930b5D//y90x5c1ta98Aef\n/qeTTz554SZ7xNbXr58yZcoJX3ume8nfvfNdIYR8az6EMLjp3w4YWPfbs+e80rGhIzvXPDbr\nmpt+9viIAcM/9MFd61+48czHVmy4Nkopv+qrp3wnU9XvgqNHb3bs7RoMYLMcsQPS5phT9/7K\npU8cMH3WF/55em7ZC7dedc3rw+vCa/nuFc65Z+5Ne59yxNj9jzvpmHeMH/r7h+783v1/mnT6\n904dsfGBsSF/95XDdv2PBy/5hyNfPmPKfnsVV7867zs3V9cOu+jyA0MImeohP7ntU+OPu2bS\nuGln/PPMUbWr77rphqWFXa774ekhVF1/95d/8b7z3z/2HaededyYge2//PEt9/2xZfr5Dx7a\n0O+tJt/2wQA2L+635QJsq7e63En/hkN7LikWWr/9uZMnNI2qzWRCCG9736xfLTgi9LjcSalU\nWv3izz9x7LRRDQPr6odOnDz1wpvuzRU3v9G2Zb/+zImH7Tl8cE1V9aBhe0w79sy7nmnuucJL\n995wzMH7D66v7bdL40HTT/zegqXdNy351e0nzXj3sMEDavoPGnvQIV+55eEtT75dgwFsymfF\nAqlVzK59bUV+zz2Gxj0IQB8RdgAAKeGMXACAlBB2AAApIewAAFJC2AEApISwAwBICWEHAJAS\nwg4AICWEHQBASgg7AICUEHYAACkh7AAAUkLYAQCkxP8H2Qy5gfv46t4AAAAASUVORK5CYII="
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    },
    {
     "data": {
      "image/png": "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\n8vKdO3deu3YtFosZjUae551OJ8Mwe/fupXcrfvTRRwMDA06nUyQS5ebm7t69e/GC2WAw6PV6\nBQJBVlZWqmIvXrx47ty5UChkNBoJIf39/Xa7/fHHHz948ODqDh42L4QdAMDGi0QiP//5z+n9\nZwqFwmaz9fb2WiyW559//m52kV1yTYuiV3GkUinDMEt+iW50Mjw8fPXqVZlMlrqe5/V6Ozo6\n8vPzjx49WlRU9PLLL8/OztJrb6nVGCUlJRKJxOv1pvYrjkQisVhs27ZtGo2GYRh6xjw99XXb\ntm379u1beevB/v7+kZGRbaWlgn/4B9ZiIYRIDh2y1ddfb29/5ZVXDhw4cOXKlZ6eHpVKlUwm\nOY7buXPnww8/vMIDyuVypVK5a9eu+fn5cDgskUi0Wm0oFOI4zu/3X7hwYXJyUigUer1eiUSi\nVqu7urq0Wu3LL78sEAgYhunp6ZmamlIoFFVVVZWVlZ/74i9HJBKdOHFCp9PRU9SEQqHJZGpu\nbm5tbU0mk++///7NmzcLCwu3b98uFApDodCFCxdYlj116lQ8Hr9+/fqNGzfofKter29padm/\nf//8/Py1a9dYlt25cyd9ivz8/NHR0StXruzYsQPn7AGFsAMA2HgdHR3d3d2FhYV6vZ7n+enp\n6cnJyX/6p3+y2+3Hjx/fuXPnynNtRUVFAwMDi+dw6SkLtbW1eXl5t2/fjsViqbMKGIbx+/1N\nTU0TExPBYHDx3f0mk8nr9fb39x85coTemkZXUy5+rtbW1k8//TQQCNhsNolEwrKsQCDQarUP\nP/ywVCp977332tvbo9GoWq2enZ0dGBgYHh5+8cUXVziJ1el0JiMRwT/8Azs8TAiRHDqk+PKX\nzS6X2+2en58/duwYnTuemZnRarUlJSUqlaq3tzcWixkMhtraWnrtarGSkhKTyTQ9PV1cXEyf\nN5lMjo2NNTU1LSwsdHZ2xuPxhYUF+lrRO9Vu3br12GOPLSwsvPbaa1evXg0Gg3Q/4ZMnT377\n29++73UVarX6qaee2r9/v8fjEYvFZrOZrsYdHh4eHR0tKSkxGo30ufLy8jiOGxgYaG1t7ejo\nuHTpklgslsvlAoFgZmbm3XffDYfD2dnZHo9nyWqMwsJCu90+PT2NsAMKYQcAsPGGhoZEIpFe\nr6dXjGw2WywW8/v9n3zySTAYbGxsfOaZZ1aYlq2rq+vr6xsYGCgtLVWpVNFo1Gq1Zmdn79mz\n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\nPHhwTExMZWVlcnKytKW9vb2xsXH06NHsrgPcSPZj7H46KPLo27+ptPzgDzWnteaJ145EJN0p\n9+gAfFxTU1NpaWl8fHznJUJSUlLq6+uPHz/uxYl5wHlVnRBizJgxqamp+fn5p06damtrq62t\nPXz48ODBg8eOHeupKQshRGRk5Lx582bOnKnRaJqbmx0OR25u7vz589PS0rr5qqysrAkTJtjt\ndumox4KCgtLS0uzs7GnTpnlq4kBQkH2P3V3/fOyZnGXDs2Y89PMlk0am6ZW24wU7/u+FP6xt\nsD+x+qdyjw7AxxmNRovF0uXNOIVCoVAojEajt2blAedbdUKIfv36zZs3b8OGDSUlJbW1tTqd\nbty4cdOmTev1Ysi9FhcXd+21106fPr2lpUU6B6Kbo+skSqVy7ty5gwYNys/PLy4u7tevX1pa\n2pgxY9hdB7iX7GEXO+Jn+V+o5t356BP3b+rYGBKb9bsPP35sLGsXAcFOr9frdDqTydR5o8vl\ncrlcsh565XK5rFarTqc7901l0Iuqk6SkpCxcuLCurq6trS0iIiIuLu6cRSUThUIRExPTeQXj\nc1IqldnZ2dnZ2XV1daxdB8jEE68Ig2bfv6v8rsPbN+47Um50qBOHDJ82dUyk6vwO9TU3Nzkj\no/VKNx8gDAQwl8tVVFRUUlLS1NQUHR09aNCgrKwsX7t8U0xMzJAhQzZv3hwXFye9G+tyucrL\ny+Pi4gYPHizHiM3Nzdu3bz927JjJZIqJiRk1alRubu6Zi/HKp9dVJ1GpVP369evXr59sE5Sd\n20/1ANDBM3/qOWuOl4+YMGvEBGGu3fX7/12+9ttvr/zJvbOG9HT1AXPDtp/c/oeL3/zgzn5h\nsk4U8Bi73X7s2LH6+nqXy9WnT5+srCz37nqx2+1fffXVjh07GhoaNBqNdHmoiy666Morr5RW\nQfMdM2bMaGhoOHLkiFar1Wq1bW1tMTExEydO7P6Yrd6pra396KOPjh49GhISotPpqqqqjhw5\nUlZWdt1113mm7S6w6gCge7KHnbVl281Trvi8pJ+1Pd9lb7p62NT/NJiEEG++8Pbyo4cWppz7\n6AqX0/TGr15uc7hh2VLAR9TX169evTo/P19a0DU8PHzYsGFz5sxJSEhw1xAHDhzYvHmzTqfL\nycmRdpDU1NRs2bIlMTGx+7MXPa9fv3633HJLxzp2o0ePvsB17Lrx3XffFRQUdD4Dt7a2dvfu\n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\nkqDYAQAASOI3dA9urioVfpMAAAAASUVORK5CYII="
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    },
    {
     "data": {
      "image/png": "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\nifPnzxsMhgVvrRILBn0/+hFdA7vxxRcP/uQnN7y2xNatW9va2i5fvszn82lfCgQCnU63a9eu\npbi6A8dxvb29ly9fnpqaEgqFpaWlO3bsSO5pnJ2dndxr5pZkZ2fX1ta6XK5AIKBWq9Vq9ewf\nm3a7XSgULtY3y5L+ElwG8Xjc7/fPeU9mKovFshQPmzlhBwCQUnw+33/+5392dHQkEolYLNbW\n1tbV1TU4OPjEE080Nzd3dnaWl5cnT733er3t7e3l5eW7du06cuRIS0uLy+Wi593rdLrt27ff\nd999ly9fbmxspKlHP8putzc2NhqNxoaGhvkHYzabzWazy+VSq9XFxcXV1dV0i2OGYejh4HA4\nLBKJ5HI5vaWrq6upqcnj8Tgcjmg0SvcZmZiYKCws3Lx58zyTdizLdnV1dXd3T01NqVSqsrKy\n7du3y2Sy2deWqHz22ZupOkIIvXSEzWbzer00hjweD71O6819EQjLsjc/xXjixInTp0/PzMwo\nlcpEItHb29vb2/v444/Ps2feTaIXq0j36oK0gLADAFgSFy9evHz5cklJiVwun5mZ0el0Lper\ntbW1rKysr69vzuZqKpWKz+fTGbJPPvmEnj9HG2tiYuLcuXMGg6G3tzcWiyUvk0UIyc3NnZ6e\nNplM84Qdy7JHjx5tbGycnp6mpZiVlbVp0ya6he8nn3zS2tpqt9tjsRifz9fpdIlEYt++fSaT\nqaenJ5FICAQCuj2v3W632+0tLS3PPvusUqm85nMlEokjR440Njb6fD65XD48PNze3t7T0/P4\nQw+dfu655C7Em7/73Zu8DqzJZLJYLEqlMh6PR6NRPp+vUCh8Pt/Fixe3bt06T7HRubf29vap\nqSmJRELn3pKzYjMzMyaTyeVyiUSivLy8DRs2CASC0dHR8+fPx+PxmpoaGpGxWMxkMn388ccv\nvPBCim8TCJCEdyoAwOLjOK67u1ssFqtUquTpUzqdbnJysqenJxgMXn3wlG6NZjKZIpFIcqdZ\nhmGMRmNHRwcNkatPwpPL5W63e54Niru6us6ePcswTHJzYKvVeuHCBYPBUFxc7HK5hoeH8/Ly\nVCpVKBRqa2vT6XQFBQUnTpxwu935+flSqZQ+TiwWm5iY6O3tnWdftO7u7sbGRpFIlFxXGwgE\nutra2NdfD3V0EEI2vvjiur/8y86urqKiory8vBvuG2wymfr7+xUKxbp16+g5MH6/f3Jysqmp\n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\njZ4HSc+xk8lk9GUxGAzT09MdHR10Xo0ujDCbzTt37ty+fbvZbDaZTCUlJXS5Bp1WrKuru14B\nE0KqqqroV0QkEiVX4DocjsrKSr1e397eTgcTi8XoV59OGc6/nR4AhbADACChUCgcDic3QksS\ni8W0sRZgx44dZrO5u7s7KysrGo0GAoGZmZl169Zt3brVbrefOnWKEBIIBOidFQoFwzANDQ35\n+fm9vb305DMej8eyrFAo5PF4dA4vPz//qaeecrlcPp9PqVRqtVqaBXw+n66gnI3uP1dcXJyT\nk6PX62kOqlSq8vJyuk7W4XAEAoGBgQH6XBzH0dgSi8Xnz5+nB3yTCzNFItGaNWt27949+yl+\ntxPKp68DG3/oIVN3N71gV21t7Z49eyorK48fP07DLjc3l2EYHo/n8/l8Pt/ExEQgEFCpVFKp\ndHBwkI5ZJpMVFhby+XyTydTb2ysSibKzs+kxXLfb7Xa729raqqurpVKp0Wj0+/30ZaSTXhzH\n0ZmzW2U0GlUq1fnz5+mVc+m0HMdxDQ0Ner2e4zg6NvL7LfToK6NUKh988EE+nz84OEiPDisU\nivr6+oMHD9K7BQIBk8nkcDgEAkFubu769evp8WJCiEAgEAgE9GH5fD4NaIFAIBKJLBaL1Wql\nV8hVq9U5OTlzrkEHcD0IOwDIZPNca2s2qVQqkUimp6fn3B6JROY5U2p+eXl5zzzzzJkzZ/r7\n+71er0aj2b59+65duzQajUQi8Xg8kUikqKhIJBJFIpGRkRGVSiWTyXJycuhyVI1GQ2e26I4Y\nOTk5tOGueTn54uLirq6u5IbG5Pfb9m7evHnz5s3vv//+r3/962AwSKeU2tratm7dum3btpGR\nEbo2QqFQCIXCeDxOT8iz2+19fX1+v1+tVtMZR51OR/fA+/jjj9euXZtIJDo7O00mk81mU8tk\n8Tfe8F2+TAip+aM/OvD66zNut1KlmpiYyMrKWr9+PV0VMT4+LpPJdDqd1+ul02BqtVqhUIRC\nIXo12EAgkEgkgsEg3dtZr9fTFcR+v3/9+vX0i0iXXIyNjV28eDESiTgcjrq6OjrBJhKJ1Gq1\nRCKhh0rpbnmzS8jpdObl5el0OvpXjuO8Xq9YLE6ueyguLmZZtru7m8fjqVQqlmVHRkboWl2H\nw5GTk1NSUjIyMkKbLy8vLycnh14Do6ys7IUXXqBb3PH5fLrFHR3w0NDQ+++/bzabafPJZLJ1\n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\n4PgzBwMM9ykmiAcgiqJ4lK4aHplppXZZZpKWlmV3dmxm2bltv9Vus+1yt3u3XS3b2tLUNMkz\n01I0vEAB5T7nPn5/jDsRIiDwzrzzzvfz1/AyzPM0MeOXd973eXtIPQEAHua6glZlZWVycrJr\n2V5vz+g3er3+uuuuc1154sx6U6vV/fv379+/fxsfzfWJresyqa4j8ywWS1VVlWuVk507dxYX\nF7sOv6uqqoqOjo6IiPj5559//PHHcw07q8GwasqU4+vXCyF6z5wZe8sttXV1rkuKtZyeQogx\nY8asXbt2165dGo1GrVY7HA6bzRYaGjp27Ng2ngDbKUJDQ93LvriZTCa9Xt/kqhuNJSYmhoWF\nlZWVxcXFubbY7fZTp04NGTLkzFVdAAgPhN1f7vk8tNvsA+ve1KtP/6E2dOxVQ7InOZIT/nHn\nUnHlK1JPAEDLamtry8rKrFZrTEyM+5/P9rHZbFu2bMnNzS0vLzcYDDExMf369XNd4aCzZttx\narU6MzMzMzOz4w9lsVjCwsIyMjLq6+srKyvr6up0Ol2PHj1cZ926rsegVqvdQaPVaoODgwsL\nC89pFFfVFX77rRAi85ZbXOvVtf3Hk5KSunTpUlVV5XA4hBAOh0OlUsXGxvbs6dEV47t37x4e\nHl5SUtK1a1fXFpPJ5LoQWQs7Dvv16zd48OCtW7dWVlZGRERYrdby8vLu3btnZ2fL6g8GQD4k\nD7uPywxpj97trjoXlVp/9x19/rb4IyEIO8BrbDbb1q1bc3NzKysr7XZ7eHj4oEGDsrOz272Q\nxJYtW9asWaNWq7t162az2SwWy+bNm2tra3Nycjx2LJcnBQUFhYWFBQcHZ2Zm1tTUmM3m4ODg\niIiIvXv3xsTEnDhx4sz4cO0za/lhnU5nXl7esWPHKisrI0NCyp5/vmLrVtGuqhNCHDp0qHv3\n7pmZmUeOHKmtrQ0JCenRo4fJZDp06NCYMWPO6aE6ol+/fueff/7WrVt//vlnrVar0WiMRqPr\n4rkt/JRWq502bdp55523c+fO+vp6vV4/evToUaNGtbqfEvBbkoddqFptOmU6c7vplEml4fwJ\nwJs2b978n//8RwiRkJCg0WgqKyu//vrr6urqGTNmtGMBWIPBsH37diFESkqKw+EwmUyRkZHB\nwcEHDx7My8sbMmRI5/8HeJvro9v8/HzXNSeEEE6n88SJE+Hh4f369bPb7ceOHWt8iJjD4Who\n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\nAEAh/h8Tw4TQUg50mgAAAABJRU5ErkJggg=="
     },
     "metadata": {
      "image/png": {
       "height": 420,
       "width": 420
      }
     },
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Create a plotting function, that we can run over all 5 personality traits\n",
    "plots_fx <- function(pers_trait){\n",
    "  trainset_df %>%\n",
    "    filter(trait == pers_trait) %>%\n",
    "    ggplot(aes(x = true_score, y = pred_score)) +\n",
    "    geom_point(alpha = .4) +\n",
    "    geom_abline(intercept = 0, slope = 1, color = \"darkred\") +\n",
    "    scale_x_continuous(name = \"True score\",\n",
    "                       limits = c(0,7.5)) +\n",
    "    scale_y_continuous(name = \"Predicted score\",\n",
    "                       limits = c(0,7.5)) +\n",
    "    theme_light()+\n",
    "    theme(aspect.ratio = 1) +\n",
    "    labs(title = pers_trait)\n",
    "}\n",
    "\n",
    "plots_fx(\"Extr\")\n",
    "plots_fx(\"Agr\")\n",
    "plots_fx(\"Cons\")\n",
    "plots_fx(\"Emot\")\n",
    "plots_fx(\"Open\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "88426d7c",
   "metadata": {
    "papermill": {
     "duration": 0.032074,
     "end_time": "2023-12-10T23:27:11.870616",
     "exception": false,
     "start_time": "2023-12-10T23:27:11.838542",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "The visual inspection reflects the adjusted R² values: The model doesn't fit perfectly, especially for Emotional Stability and Openness, the predicted scores resemble more or less a horizontally oriented cloud than the diagonale line.\n",
    "\n",
    "However from earlier experience, these two traits are usually the hardest to predict using the features at hand. Therefore, we continue with our prediction."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "88298a1d",
   "metadata": {
    "_cell_guid": "d2def0aa-2cf4-47cf-b2f5-31477c6bffda",
    "_uuid": "04dc5694-5fba-4712-b6a0-5e8ea30ded86",
    "papermill": {
     "duration": 0.030367,
     "end_time": "2023-12-10T23:27:11.931131",
     "exception": false,
     "start_time": "2023-12-10T23:27:11.900764",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# 4. Making predictions on the test set\n",
    "Next, we use our model for predicting the personality scores for the test set (n = 80)."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f6cb72da",
   "metadata": {
    "_cell_guid": "560128db-06d2-493a-9b78-9fa2ff25881f",
    "_uuid": "d4c0a598-8241-4d91-a60b-cc964318422d",
    "papermill": {
     "duration": 0.030358,
     "end_time": "2023-12-10T23:27:11.991823",
     "exception": false,
     "start_time": "2023-12-10T23:27:11.961465",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.1 Predictions\n",
    "Predict the scores using our model and store the scores in a data frame."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 26,
   "id": "0c8bb47d",
   "metadata": {
    "_cell_guid": "9453537e-1d01-45a9-bfb7-b91b891e7b1e",
    "_uuid": "9263474a-b2a7-4073-88e4-57af25295b0f",
    "collapsed": false,
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:12.058993Z",
     "iopub.status.busy": "2023-12-10T23:27:12.056997Z",
     "iopub.status.idle": "2023-12-10T23:27:12.113865Z",
     "shell.execute_reply": "2023-12-10T23:27:12.111518Z"
    },
    "jupyter": {
     "outputs_hidden": false
    },
    "papermill": {
     "duration": 0.094208,
     "end_time": "2023-12-10T23:27:12.116841",
     "exception": false,
     "start_time": "2023-12-10T23:27:12.022633",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "pred_ex <- predict(model_ex, new = test_data)\n",
    "pred_ag <- predict(model_ag, new = test_data)\n",
    "pred_co <- predict(model_co, new = test_data)\n",
    "pred_em <- predict(model_em, new = test_data)\n",
    "pred_op <- predict(model_op, new = test_data)\n",
    "\n",
    "#combining prediction\n",
    "testset_pred = cbind(\n",
    "    Extr = pred_ex,\n",
    "    Agr = pred_ag,\n",
    "    Cons = pred_co,\n",
    "    Emot = pred_em,\n",
    "    Open = pred_op\n",
    "    ) %>%\n",
    "    as.data.frame() %>%\n",
    "    #add vlogId from test_data\n",
    "    cbind(test_data$vlogId,.) %>%\n",
    "    rename(vlogId = 1)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "7a844566",
   "metadata": {
    "_cell_guid": "4528893d-1930-4ccf-b4c0-51a0c773dae5",
    "_uuid": "2ef3a62f-62cf-42ca-9f50-c07a93d04ccf",
    "papermill": {
     "duration": 0.029572,
     "end_time": "2023-12-10T23:27:12.176701",
     "exception": false,
     "start_time": "2023-12-10T23:27:12.147129",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.2 Writing predictions to file\n",
    "Here, we prepare the \"predictions.csv\" in order to return an interpretable output for the Kaggle competition submission."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "id": "bcab55c7",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:27:12.241176Z",
     "iopub.status.busy": "2023-12-10T23:27:12.239288Z",
     "iopub.status.idle": "2023-12-10T23:27:12.374541Z",
     "shell.execute_reply": "2023-12-10T23:27:12.372263Z"
    },
    "papermill": {
     "duration": 0.170169,
     "end_time": "2023-12-10T23:27:12.377237",
     "exception": false,
     "start_time": "2023-12-10T23:27:12.207068",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 3</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>vlogId</th><th scope=col>pers_axis</th><th scope=col>value</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>VLOG8 </td><td>Extr</td><td>4.389302</td></tr>\n",
       "\t<tr><td>VLOG8 </td><td>Agr </td><td>5.004084</td></tr>\n",
       "\t<tr><td>VLOG8 </td><td>Cons</td><td>3.994731</td></tr>\n",
       "\t<tr><td>VLOG8 </td><td>Emot</td><td>4.805673</td></tr>\n",
       "\t<tr><td>VLOG8 </td><td>Open</td><td>4.448317</td></tr>\n",
       "\t<tr><td>VLOG15</td><td>Extr</td><td>3.998947</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 3\n",
       "\\begin{tabular}{lll}\n",
       " vlogId & pers\\_axis & value\\\\\n",
       " <chr> & <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t VLOG8  & Extr & 4.389302\\\\\n",
       "\t VLOG8  & Agr  & 5.004084\\\\\n",
       "\t VLOG8  & Cons & 3.994731\\\\\n",
       "\t VLOG8  & Emot & 4.805673\\\\\n",
       "\t VLOG8  & Open & 4.448317\\\\\n",
       "\t VLOG15 & Extr & 3.998947\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 3\n",
       "\n",
       "| vlogId &lt;chr&gt; | pers_axis &lt;chr&gt; | value &lt;dbl&gt; |\n",
       "|---|---|---|\n",
       "| VLOG8  | Extr | 4.389302 |\n",
       "| VLOG8  | Agr  | 5.004084 |\n",
       "| VLOG8  | Cons | 3.994731 |\n",
       "| VLOG8  | Emot | 4.805673 |\n",
       "| VLOG8  | Open | 4.448317 |\n",
       "| VLOG15 | Extr | 3.998947 |\n",
       "\n"
      ],
      "text/plain": [
       "  vlogId pers_axis value   \n",
       "1 VLOG8  Extr      4.389302\n",
       "2 VLOG8  Agr       5.004084\n",
       "3 VLOG8  Cons      3.994731\n",
       "4 VLOG8  Emot      4.805673\n",
       "5 VLOG8  Open      4.448317\n",
       "6 VLOG15 Extr      3.998947"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 2</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>Id</th><th scope=col>Expected</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>VLOG8_Extr </td><td>4.389302</td></tr>\n",
       "\t<tr><td>VLOG8_Agr  </td><td>5.004084</td></tr>\n",
       "\t<tr><td>VLOG8_Cons </td><td>3.994731</td></tr>\n",
       "\t<tr><td>VLOG8_Emot </td><td>4.805673</td></tr>\n",
       "\t<tr><td>VLOG8_Open </td><td>4.448317</td></tr>\n",
       "\t<tr><td>VLOG15_Extr</td><td>3.998947</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 2\n",
       "\\begin{tabular}{ll}\n",
       " Id & Expected\\\\\n",
       " <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t VLOG8\\_Extr  & 4.389302\\\\\n",
       "\t VLOG8\\_Agr   & 5.004084\\\\\n",
       "\t VLOG8\\_Cons  & 3.994731\\\\\n",
       "\t VLOG8\\_Emot  & 4.805673\\\\\n",
       "\t VLOG8\\_Open  & 4.448317\\\\\n",
       "\t VLOG15\\_Extr & 3.998947\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 2\n",
       "\n",
       "| Id &lt;chr&gt; | Expected &lt;dbl&gt; |\n",
       "|---|---|\n",
       "| VLOG8_Extr  | 4.389302 |\n",
       "| VLOG8_Agr   | 5.004084 |\n",
       "| VLOG8_Cons  | 3.994731 |\n",
       "| VLOG8_Emot  | 4.805673 |\n",
       "| VLOG8_Open  | 4.448317 |\n",
       "| VLOG15_Extr | 3.998947 |\n",
       "\n"
      ],
      "text/plain": [
       "  Id          Expected\n",
       "1 VLOG8_Extr  4.389302\n",
       "2 VLOG8_Agr   5.004084\n",
       "3 VLOG8_Cons  3.994731\n",
       "4 VLOG8_Emot  4.805673\n",
       "5 VLOG8_Open  4.448317\n",
       "6 VLOG15_Extr 3.998947"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<style>\n",
       ".list-inline {list-style: none; margin:0; padding: 0}\n",
       ".list-inline>li {display: inline-block}\n",
       ".list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "</style>\n",
       "<ol class=list-inline><li>'__MACOSX'</li><li>'__notebook__.ipynb'</li><li>'NRC-Emotion-Lexicon'</li><li>'NRC-Emotion-Lexicon.zip'</li><li>'nrc.rds'</li><li>'predictions.csv'</li><li>'Rplot001.png'</li><li>'Rplot002.png'</li><li>'Rplot003.png'</li><li>'Rplot004.png'</li><li>'Rplot005.png'</li><li>'submission.csv'</li><li>'swear_words.txt'</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item '\\_\\_MACOSX'\n",
       "\\item '\\_\\_notebook\\_\\_.ipynb'\n",
       "\\item 'NRC-Emotion-Lexicon'\n",
       "\\item 'NRC-Emotion-Lexicon.zip'\n",
       "\\item 'nrc.rds'\n",
       "\\item 'predictions.csv'\n",
       "\\item 'Rplot001.png'\n",
       "\\item 'Rplot002.png'\n",
       "\\item 'Rplot003.png'\n",
       "\\item 'Rplot004.png'\n",
       "\\item 'Rplot005.png'\n",
       "\\item 'submission.csv'\n",
       "\\item 'swear\\_words.txt'\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. '__MACOSX'\n",
       "2. '__notebook__.ipynb'\n",
       "3. 'NRC-Emotion-Lexicon'\n",
       "4. 'NRC-Emotion-Lexicon.zip'\n",
       "5. 'nrc.rds'\n",
       "6. 'predictions.csv'\n",
       "7. 'Rplot001.png'\n",
       "8. 'Rplot002.png'\n",
       "9. 'Rplot003.png'\n",
       "10. 'Rplot004.png'\n",
       "11. 'Rplot005.png'\n",
       "12. 'submission.csv'\n",
       "13. 'swear_words.txt'\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       " [1] \"__MACOSX\"                \"__notebook__.ipynb\"     \n",
       " [3] \"NRC-Emotion-Lexicon\"     \"NRC-Emotion-Lexicon.zip\"\n",
       " [5] \"nrc.rds\"                 \"predictions.csv\"        \n",
       " [7] \"Rplot001.png\"            \"Rplot002.png\"           \n",
       " [9] \"Rplot003.png\"            \"Rplot004.png\"           \n",
       "[11] \"Rplot005.png\"            \"submission.csv\"         \n",
       "[13] \"swear_words.txt\"        "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "testset_pred_long <- testset_pred %>%\n",
    "  pivot_longer(c(Extr, Agr, Cons, Emot, Open), names_to = \"pers_axis\")\n",
    "\n",
    "head(testset_pred_long)\n",
    "\n",
    "# Obtain the right format for Kaggle\n",
    "testset_pred_final <- testset_pred_long %>%\n",
    "    unite(Id, vlogId, pers_axis) %>%\n",
    "    dplyr::rename(Expected = value)\n",
    "\n",
    "# Check if we succeeded\n",
    "head(testset_pred_final)\n",
    "\n",
    "# Write to csv\n",
    "write_csv(testset_pred_final, file = \"predictions.csv\")\n",
    "write_csv(testset_pred_final, file = \"submission.csv\")\n",
    "\n",
    "\n",
    "\n",
    "# Check if the file was written successfully.\n",
    "dir()\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2f088e7a",
   "metadata": {
    "papermill": {
     "duration": 0.030089,
     "end_time": "2023-12-10T23:27:12.437339",
     "exception": false,
     "start_time": "2023-12-10T23:27:12.407250",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# References\n",
    "Laserna, C. M., Seih, Y.-T., & Pennebaker, J. W. (2014). Um . . . Who Like Says You Know: Filler Word Use as a Function of Age, Gender, and Personality. Journal of Language and Social Psychology, 33(3), 328–338. https://doi.org/10.1177/0261927X14526993\n",
    "\n",
    "Lee, S., Park, J., & Um, D. (2021). Speech Characteristics as Indicators of Personality Traits. Applied Sciences, 11(18), Article 18. https://doi.org/10.3390/app11188776\n",
    "\n",
    "Lin, H., Wang, C., & Hao, Q. (2023). A novel personality detection method based on high-dimensional psycholinguistic features and improved distributed Gray Wolf Optimizer for feature selection. Information Processing & Management, 60(2), 103217. https://doi.org/10.1016/j.ipm.2022.103217\n",
    "\n",
    "Scully, I. D., & Terry, C. P. (2011). Self-Referential Memory for the Big-Five Personality Traits. Psi Chi Journal of Psychological Research, 16(3), 123–128. https://doi.org/10.24839/1089-4136.JN16.3.123\n",
    "\n"
   ]
  }
 ],
 "metadata": {
  "kaggle": {
   "accelerator": "none",
   "dataSources": [
    {
     "databundleVersionId": 6559293,
     "sourceId": 60846,
     "sourceType": "competition"
    }
   ],
   "dockerImageVersionId": 30530,
   "isGpuEnabled": false,
   "isInternetEnabled": true,
   "language": "r",
   "sourceType": "notebook"
  },
  "kernelspec": {
   "display_name": "R",
   "language": "R",
   "name": "ir"
  },
  "language_info": {
   "codemirror_mode": "r",
   "file_extension": ".r",
   "mimetype": "text/x-r-source",
   "name": "R",
   "pygments_lexer": "r",
   "version": "4.0.5"
  },
  "papermill": {
   "default_parameters": {},
   "duration": 22.065162,
   "end_time": "2023-12-10T23:27:12.592991",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2023-12-10T23:26:50.527829",
   "version": "2.4.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
