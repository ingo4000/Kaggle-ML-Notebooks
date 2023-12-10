{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "b310d93a",
   "metadata": {
    "papermill": {
     "duration": 0.020076,
     "end_time": "2023-12-10T23:16:41.396980",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.376904",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<div style=\"font-size:24px; \n",
    "            text-align:center;\n",
    "            border-radius: 0px 0px 50px 50px;\n",
    "            background: #FF9900;\n",
    "            color: #000000;\n",
    "            padding: 10px;\">\n",
    "    <b>\n",
    "        Amazon Customer Satisfaction Recognition - BDA Competition 2023\n",
    "    </b>\n",
    "    <br>        \n",
    "    <span style='font-size:18px;'>\n",
    "        Round 1, Group 6\n",
    "    </span>\n",
    "</div>\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f264a1fe",
   "metadata": {
    "papermill": {
     "duration": 0.018196,
     "end_time": "2023-12-10T23:16:41.433530",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.415334",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "In this competition, we build a classifier to recognize customers' satisfaction  toward baby products on Amazon automatically based on textual reviews and 5 star ratings. \n",
    "\n",
    "The current data contain 32,418 unique values for names, 182,643 texual reviews, and ratings with the composition of (49% 5 stars, 16% NA, and 35% others). \n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "6192cb3b",
   "metadata": {
    "papermill": {
     "duration": 0.018359,
     "end_time": "2023-12-10T23:16:41.470171",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.451812",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# Overview to this notebook\n",
    "\n",
    "[1️⃣ The Project](#the_project)   \n",
    "[2️⃣ Data import](#data_import)   \n",
    "[3️⃣ Preprocessing](#preprocessing)   \n",
    "[4️⃣ Feature engineering](#feature_engineering)   \n",
    "[5️⃣ Models](#model)   \n",
    "[6️⃣ Prediction on the Test Data, Submission, & Conclusion](#prediction_test)   \n",
    "[7️⃣ Divison of Labor \\& References](#div_labor_refs) "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "59c61906",
   "metadata": {
    "papermill": {
     "duration": 0.018454,
     "end_time": "2023-12-10T23:16:41.506832",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.488378",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = project style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "    1. The project\n",
    " </h1>\n",
    "\n",
    "In this competition you will predict customer sentiments regarding [Baby products purchased on Amazon.com](http://jmcauley.ucsd.edu/data/amazon/), on the basis of their written reviews. \n",
    "\n",
    "\n",
    "### Data Source and Generalization\n",
    "The dataset contains written reviews and their ratings of various baby products. The reviews are written in English and given the nature of the products reviewed it is reasonable to assume that the authors of the reviews are primarily parents. Consequently, our ability to generalize our findings is constrained to a specific population: English-speaking parents who review baby products.\n",
    "\n",
    "### Possible Features and Models\n",
    "The core idea of this competitions is about automatic feature selection. The features to be selected are generated through TF-IDF. Suitable approaches for automatic features selection are the lasso, ridge regression, principal component regression and partial least squares. The selected features will be used for classification.\n",
    "\n",
    "### Bayes' Error Bound\n",
    "Humans have the capability to discern positive from negative reviews by analyzing the overall meanings of sentences or paragraphs and integrating multiple text segments and their meanings to draw coherent conclusions. Considering the nature of our task, the Bayes' error bound is likely to be quite low. Human performance in classifying reviews as \"satisfied\" or \"unsatisfied\" based on various text features is generally strong. However, reviews are not always perfectly alligned with the rating a customer gives or there can be erros in the review text. All things considered we expect the Bayes' Error Bound the be around 90%. \n",
    "\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "4cd7988d",
   "metadata": {
    "_uuid": "ea195a804433c840f3dab99683f4e8b9e69c55a0",
    "papermill": {
     "duration": 0.018849,
     "end_time": "2023-12-10T23:16:41.544803",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.525954",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = data_import style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "2. Data Import\n",
    "</h1>\n",
    "\n",
    "We start with loading necessary packages and loading our data."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "ac3e10c1",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:16:41.588012Z",
     "iopub.status.busy": "2023-12-10T23:16:41.585197Z",
     "iopub.status.idle": "2023-12-10T23:16:46.877907Z",
     "shell.execute_reply": "2023-12-10T23:16:46.875603Z"
    },
    "papermill": {
     "duration": 5.318133,
     "end_time": "2023-12-10T23:16:46.881734",
     "exception": false,
     "start_time": "2023-12-10T23:16:41.563601",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "\u001b[1mRows: \u001b[22m\u001b[34m183531\u001b[39m \u001b[1mColumns: \u001b[22m\u001b[34m3\u001b[39m\n",
      "\u001b[36m──\u001b[39m \u001b[1mColumn specification\u001b[22m \u001b[36m────────────────────────────────────────────────────────\u001b[39m\n",
      "\u001b[1mDelimiter:\u001b[22m \",\"\n",
      "\u001b[31mchr\u001b[39m (2): name, review\n",
      "\u001b[32mdbl\u001b[39m (1): rating\n",
      "\n",
      "\u001b[36mℹ\u001b[39m Use `spec()` to retrieve the full column specification for this data.\n",
      "\u001b[36mℹ\u001b[39m Specify the column types or set `show_col_types = FALSE` to quiet this message.\n"
     ]
    }
   ],
   "source": [
    "## Importing packages\n",
    "suppressPackageStartupMessages(library(tidyverse))\n",
    "suppressPackageStartupMessages(library(tidytext))\n",
    "suppressPackageStartupMessages(library(glmnet))\n",
    "suppressPackageStartupMessages(library(pls))\n",
    "suppressPackageStartupMessages(library(ROCR))\n",
    "\n",
    "# Find the right file path\n",
    "csv_filepath <- dir(\"..\", pattern=\"amazon_baby.csv\", recursive=TRUE, full.names = TRUE)\n",
    "\n",
    "# Read in the csv file\n",
    "amazon <- read_csv(csv_filepath) %>%\n",
    "    rownames_to_column('id') "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "985e6486",
   "metadata": {
    "papermill": {
     "duration": 0.019541,
     "end_time": "2023-12-10T23:16:46.920611",
     "exception": false,
     "start_time": "2023-12-10T23:16:46.901070",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = preprocessing style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "3. Preprocessing\n",
    "</h1>\n",
    "\n",
    "Given the variance in product quality, which would affect rating, we prepend the product name to the respective review. By doing this, we combine the product name and the review into a singular string, alowing use to factor in both elements without separately managing product names. \n",
    "\n",
    "When combining the product name with the review, we ensure that even if the review is empty, the product name still offers some basis for prediction. We used the \"unite()\" ucntion to merge the product name and review with the following code:"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "id": "cb8fba9e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:16:46.995292Z",
     "iopub.status.busy": "2023-12-10T23:16:46.961221Z",
     "iopub.status.idle": "2023-12-10T23:16:48.811626Z",
     "shell.execute_reply": "2023-12-10T23:16:48.809333Z"
    },
    "papermill": {
     "duration": 1.875155,
     "end_time": "2023-12-10T23:16:48.815156",
     "exception": false,
     "start_time": "2023-12-10T23:16:46.940001",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\u001b[90m# A tibble: 183,531 × 4\u001b[39m\n",
      "   id    review                                                     name  rating\n",
      "   \u001b[3m\u001b[90m<chr>\u001b[39m\u001b[23m \u001b[3m\u001b[90m<chr>\u001b[39m\u001b[23m                                                      \u001b[3m\u001b[90m<chr>\u001b[39m\u001b[23m  \u001b[3m\u001b[90m<dbl>\u001b[39m\u001b[23m\n",
      "\u001b[90m 1\u001b[39m 1     \u001b[90m\"\u001b[39mPlanetwise Flannel Wipes — These flannel wipes are OK, b… \u001b[90m\"\u001b[39mPla…      3\n",
      "\u001b[90m 2\u001b[39m 2     \u001b[90m\"\u001b[39mPlanetwise Wipe Pouch — it came early and was not disapp… \u001b[90m\"\u001b[39mPla…      5\n",
      "\u001b[90m 3\u001b[39m 3     \u001b[90m\"\u001b[39mAnnas Dream Full Quilt with 2 Shams — Very soft and comf… \u001b[90m\"\u001b[39mAnn…     \u001b[31mNA\u001b[39m\n",
      "\u001b[90m 4\u001b[39m 4     \u001b[90m\"\u001b[39mStop Pacifier Sucking without tears with Thumbuddy To Lo… \u001b[90m\"\u001b[39mSto…      5\n",
      "\u001b[90m 5\u001b[39m 5     \u001b[90m\"\u001b[39mStop Pacifier Sucking without tears with Thumbuddy To Lo… \u001b[90m\"\u001b[39mSto…     \u001b[31mNA\u001b[39m\n",
      "\u001b[90m 6\u001b[39m 6     \u001b[90m\"\u001b[39mStop Pacifier Sucking without tears with Thumbuddy To Lo… \u001b[90m\"\u001b[39mSto…      5\n",
      "\u001b[90m 7\u001b[39m 7     \u001b[90m\"\u001b[39mA Tale of Baby\\\\'s Days with Peter Rabbit — Lovely book,… \u001b[90m\"\u001b[39mA T…      4\n",
      "\u001b[90m 8\u001b[39m 8     \u001b[90m\"\u001b[39mBaby Tracker&reg; - Daily Childcare Journal, Schedule Lo… \u001b[90m\"\u001b[39mBab…     \u001b[31mNA\u001b[39m\n",
      "\u001b[90m 9\u001b[39m 9     \u001b[90m\"\u001b[39mBaby Tracker&reg; - Daily Childcare Journal, Schedule Lo… \u001b[90m\"\u001b[39mBab…      5\n",
      "\u001b[90m10\u001b[39m 10    \u001b[90m\"\u001b[39mBaby Tracker&reg; - Daily Childcare Journal, Schedule Lo… \u001b[90m\"\u001b[39mBab…      4\n",
      "\u001b[90m# ℹ 183,521 more rows\u001b[39m\n"
     ]
    }
   ],
   "source": [
    "# Paste name and review into a single string separated by a \"–\".\n",
    "# The new string replaces the original review.\n",
    "amazon <- amazon %>% \n",
    "    unite(review, name, review, sep = \" — \", remove = FALSE)\n",
    "\n",
    "print(amazon)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "85d19a74",
   "metadata": {
    "_uuid": "6098328162f312fdc8dbc3928891e85dbf1e479a",
    "papermill": {
     "duration": 0.019143,
     "end_time": "2023-12-10T23:16:48.853345",
     "exception": false,
     "start_time": "2023-12-10T23:16:48.834202",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.1 Tokenization\n",
    "\n",
    "We're going to use tidytext to break up the text into separate tokens and count the number of occurences per review. To keep track of the review to which the review belongs, we have added the rownames as `id` above, which is simply the row number. \n",
    "\n",
    "As tokens we consider   \n",
    "* **Unigrams**: Unigrams are simply individual words..  \n",
    "* **Bigrams**: Bigrams introduce us to word combinations. These important word pairs provide us with extra clues by showing how words interact. This is really useful for spotting the different ways positive and negative reviews are put together.\n",
    "* **Trigrams**: Trigrams takes the bigrams one step further by looking into three word combinations. This increases the understanding of words within context."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "id": "0440b7fd",
   "metadata": {
    "_uuid": "fca425b0d51862febe3d304fe00b95b7d0cd0769",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:16:48.896170Z",
     "iopub.status.busy": "2023-12-10T23:16:48.894321Z",
     "iopub.status.idle": "2023-12-10T23:16:48.911159Z",
     "shell.execute_reply": "2023-12-10T23:16:48.909236Z"
    },
    "papermill": {
     "duration": 0.041926,
     "end_time": "2023-12-10T23:16:48.914554",
     "exception": false,
     "start_time": "2023-12-10T23:16:48.872628",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# For testing purposes we set up a sample data frame.\n",
    "# For final submission, disable this code chunk\n",
    "#set.seed(1)\n",
    "#amazon <- amazon %>% sample_n(5000)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "03f9b353",
   "metadata": {
    "papermill": {
     "duration": 0.018821,
     "end_time": "2023-12-10T23:16:48.952685",
     "exception": false,
     "start_time": "2023-12-10T23:16:48.933864",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "**A) Tokenization at unigram level**"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "aa7dd6a6",
   "metadata": {
    "_uuid": "fca425b0d51862febe3d304fe00b95b7d0cd0769",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:16:48.995701Z",
     "iopub.status.busy": "2023-12-10T23:16:48.994053Z",
     "iopub.status.idle": "2023-12-10T23:19:43.276969Z",
     "shell.execute_reply": "2023-12-10T23:19:43.274805Z"
    },
    "papermill": {
     "duration": 174.308317,
     "end_time": "2023-12-10T23:19:43.280293",
     "exception": false,
     "start_time": "2023-12-10T23:16:48.971976",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# tokenize reviews at UNIGRAM level\n",
    "reviews_unigram <- \n",
    "   amazon %>% \n",
    "   unnest_tokens(unigram, review, token = \"ngrams\", n = 1) %>%\n",
    "   # count tokens within reviews as 'n'\n",
    "   # (keep id, name, and rating in the result)\n",
    "   count(id, name, rating, unigram)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "04b83e90",
   "metadata": {
    "papermill": {
     "duration": 0.019082,
     "end_time": "2023-12-10T23:19:43.324076",
     "exception": false,
     "start_time": "2023-12-10T23:19:43.304994",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "**B) Tokenization at bigram level**"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "82a2576c",
   "metadata": {
    "_uuid": "fca425b0d51862febe3d304fe00b95b7d0cd0769",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:19:43.366775Z",
     "iopub.status.busy": "2023-12-10T23:19:43.364859Z",
     "iopub.status.idle": "2023-12-10T23:23:50.941994Z",
     "shell.execute_reply": "2023-12-10T23:23:50.939719Z"
    },
    "papermill": {
     "duration": 247.603459,
     "end_time": "2023-12-10T23:23:50.946521",
     "exception": false,
     "start_time": "2023-12-10T23:19:43.343062",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "reviews_bigram <- \n",
    "    amazon %>% \n",
    "    unnest_tokens(bigram, review, token = \"ngrams\", n = 2) %>%\n",
    "    # count tokens within reviews as 'n'\n",
    "    # (keep id, name, and rating in the result)\n",
    "    count(id, name, rating, bigram)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9aa87d4c",
   "metadata": {
    "papermill": {
     "duration": 0.019731,
     "end_time": "2023-12-10T23:23:50.991218",
     "exception": false,
     "start_time": "2023-12-10T23:23:50.971487",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "**C) Tokenization at trigram level**"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "653d97d6",
   "metadata": {
    "_uuid": "fca425b0d51862febe3d304fe00b95b7d0cd0769",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:23:51.034427Z",
     "iopub.status.busy": "2023-12-10T23:23:51.032580Z",
     "iopub.status.idle": "2023-12-10T23:29:01.771415Z",
     "shell.execute_reply": "2023-12-10T23:29:01.769309Z"
    },
    "papermill": {
     "duration": 310.764443,
     "end_time": "2023-12-10T23:29:01.775593",
     "exception": false,
     "start_time": "2023-12-10T23:23:51.011150",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "reviews_trigram <- \n",
    "    amazon %>% \n",
    "    unnest_tokens(trigram, review, token = \"ngrams\", n = 3) %>%\n",
    "    # count tokens within reviews as 'n'\n",
    "    # (keep id, name, and rating in the result)\n",
    "    count(id, name, rating, trigram)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "66298d35",
   "metadata": {
    "papermill": {
     "duration": 0.018972,
     "end_time": "2023-12-10T23:29:01.817205",
     "exception": false,
     "start_time": "2023-12-10T23:29:01.798233",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "**Merging the different tokenized data sets**"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "3574cea7",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:01.859851Z",
     "iopub.status.busy": "2023-12-10T23:29:01.857950Z",
     "iopub.status.idle": "2023-12-10T23:29:20.493993Z",
     "shell.execute_reply": "2023-12-10T23:29:20.491313Z"
    },
    "papermill": {
     "duration": 18.661849,
     "end_time": "2023-12-10T23:29:20.497969",
     "exception": false,
     "start_time": "2023-12-10T23:29:01.836120",
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
       "<ol class=list-inline><li>43737498</li><li>5</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 43737498\n",
       "\\item 5\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 43737498\n",
       "2. 5\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 43737498        5"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "all_ngram <- rbind(\n",
    "    reviews_unigram %>% rename(n_gram = unigram),\n",
    "    reviews_bigram %>% rename(n_gram = bigram),\n",
    "    reviews_trigram %>% rename(n_gram = trigram)    \n",
    ")\n",
    "\n",
    "dim(all_ngram)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d5be9400",
   "metadata": {
    "_uuid": "fdf9400f7df6154bc5376ce3c5a213f56dd0560d",
    "papermill": {
     "duration": 0.019251,
     "end_time": "2023-12-10T23:29:20.536739",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.517488",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = feature_engineering style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "4. Feature engineering\n",
    "</h1>\n",
    "\n",
    "Feature engineering is a critical step in the data preprocessing phase of machine learning. It involves creating new features (variables) from the existing data or transforming existing features to improve the performance of machine learning models. Effective feature engineering can lead to more accurate predictions and better model interpretability.\n",
    "\n",
    "## 4.1 N_grams TF-IDF matrix\n",
    "TF-IDF is a critical component of our analysis, enabling us to extract nuanced sentiment information from customer reviews. This approach aids in identifying key words by assigning weighted scores to words based on their prevalence across reviews, emphasizing unique and impactful terms while reducing the influence of common words like stopwords.\n",
    "\n",
    "TF-IDF consist of two elements the TF and IDF:\n",
    "- Term frequency: Relative frequency of a term within a document.\n",
    "- Inverse document frequency: Relative frequency with which a term occurs among the documents\n",
    "\n",
    "The TF-IDF is the product of the two elements."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "841ac3b4",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:20.579124Z",
     "iopub.status.busy": "2023-12-10T23:29:20.577373Z",
     "iopub.status.idle": "2023-12-10T23:32:23.692829Z",
     "shell.execute_reply": "2023-12-10T23:32:23.690751Z"
    },
    "papermill": {
     "duration": 183.155771,
     "end_time": "2023-12-10T23:32:23.711668",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.555897",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 8</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>id</th><th scope=col>name</th><th scope=col>rating</th><th scope=col>n_gram</th><th scope=col>n</th><th scope=col>tf</th><th scope=col>idf</th><th scope=col>tf_idf</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>12   </td><td>1</td><td>0.004016064</td><td>3.8622347</td><td>0.015510983</td></tr>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>6    </td><td>1</td><td>0.004016064</td><td>2.5988639</td><td>0.010437204</td></tr>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>8    </td><td>1</td><td>0.004016064</td><td>3.3610981</td><td>0.013498386</td></tr>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>a    </td><td>2</td><td>0.008032129</td><td>0.3625589</td><td>0.002912120</td></tr>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>about</td><td>1</td><td>0.004016064</td><td>1.9354276</td><td>0.007772801</td></tr>\n",
       "\t<tr><td>1</td><td>Planetwise Flannel Wipes</td><td>3</td><td>also </td><td>1</td><td>0.004016064</td><td>1.8976886</td><td>0.007621239</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 8\n",
       "\\begin{tabular}{llllllll}\n",
       " id & name & rating & n\\_gram & n & tf & idf & tf\\_idf\\\\\n",
       " <chr> & <chr> & <dbl> & <chr> & <int> & <dbl> & <dbl> & <dbl>\\\\\n",
       "\\hline\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & 12    & 1 & 0.004016064 & 3.8622347 & 0.015510983\\\\\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & 6     & 1 & 0.004016064 & 2.5988639 & 0.010437204\\\\\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & 8     & 1 & 0.004016064 & 3.3610981 & 0.013498386\\\\\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & a     & 2 & 0.008032129 & 0.3625589 & 0.002912120\\\\\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & about & 1 & 0.004016064 & 1.9354276 & 0.007772801\\\\\n",
       "\t 1 & Planetwise Flannel Wipes & 3 & also  & 1 & 0.004016064 & 1.8976886 & 0.007621239\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 8\n",
       "\n",
       "| id &lt;chr&gt; | name &lt;chr&gt; | rating &lt;dbl&gt; | n_gram &lt;chr&gt; | n &lt;int&gt; | tf &lt;dbl&gt; | idf &lt;dbl&gt; | tf_idf &lt;dbl&gt; |\n",
       "|---|---|---|---|---|---|---|---|\n",
       "| 1 | Planetwise Flannel Wipes | 3 | 12    | 1 | 0.004016064 | 3.8622347 | 0.015510983 |\n",
       "| 1 | Planetwise Flannel Wipes | 3 | 6     | 1 | 0.004016064 | 2.5988639 | 0.010437204 |\n",
       "| 1 | Planetwise Flannel Wipes | 3 | 8     | 1 | 0.004016064 | 3.3610981 | 0.013498386 |\n",
       "| 1 | Planetwise Flannel Wipes | 3 | a     | 2 | 0.008032129 | 0.3625589 | 0.002912120 |\n",
       "| 1 | Planetwise Flannel Wipes | 3 | about | 1 | 0.004016064 | 1.9354276 | 0.007772801 |\n",
       "| 1 | Planetwise Flannel Wipes | 3 | also  | 1 | 0.004016064 | 1.8976886 | 0.007621239 |\n",
       "\n"
      ],
      "text/plain": [
       "  id name                     rating n_gram n tf          idf       tf_idf     \n",
       "1 1  Planetwise Flannel Wipes 3      12     1 0.004016064 3.8622347 0.015510983\n",
       "2 1  Planetwise Flannel Wipes 3      6      1 0.004016064 2.5988639 0.010437204\n",
       "3 1  Planetwise Flannel Wipes 3      8      1 0.004016064 3.3610981 0.013498386\n",
       "4 1  Planetwise Flannel Wipes 3      a      2 0.008032129 0.3625589 0.002912120\n",
       "5 1  Planetwise Flannel Wipes 3      about  1 0.004016064 1.9354276 0.007772801\n",
       "6 1  Planetwise Flannel Wipes 3      also   1 0.004016064 1.8976886 0.007621239"
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
       "<ol class=list-inline><li>43737498</li><li>8</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 43737498\n",
       "\\item 8\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 43737498\n",
       "2. 8\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 43737498        8"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "## Getting the TF IDF matrix\n",
    "tf_idf_n_gram <- \n",
    "    all_ngram %>% \n",
    "    bind_tf_idf(n_gram, id, n) %>% \n",
    "    # n_grams that are not present in a particular scentence are NA's but should be 0\n",
    "    replace_na(list(tf=0, idf=Inf, tf_idf=0))\n",
    "\n",
    "head(tf_idf_n_gram)\n",
    "dim(tf_idf_n_gram)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f6485267",
   "metadata": {
    "papermill": {
     "duration": 0.019831,
     "end_time": "2023-12-10T23:32:23.751291",
     "exception": false,
     "start_time": "2023-12-10T23:32:23.731460",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.2 Structural features\n",
    "\n",
    "We now have a huge set of predictors using the TF_IDF metrics\n",
    "Additionally, we extract the following structural features that we expect to be indicative for customer satisfaction:\n",
    "\n",
    "* **Word counts**\n",
    "* **Average sentence length**\n",
    "* **Count of exclamation marks and question marks**\n",
    "* **Use of stopwords**\n",
    "\n",
    "### 4.2.1 Word counts\n",
    "Usually word counts are not very informative, but for our specific goal they can be. The number of tokens could reflect satisfaction or not. When someone is unsatisfied they might be more inclined to write a very long review indicating all the reasons why they were not satisfied. When someone is satisfied this might require less text.\n",
    "\n",
    "Confirming our idea, **Group 8** found literature supporting this idea (Eslami, Deal, & Hassanein, 2018).\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "8eb88155",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:23.796428Z",
     "iopub.status.busy": "2023-12-10T23:32:23.794387Z",
     "iopub.status.idle": "2023-12-10T23:32:26.175291Z",
     "shell.execute_reply": "2023-12-10T23:32:26.173202Z"
    },
    "papermill": {
     "duration": 2.406982,
     "end_time": "2023-12-10T23:32:26.178137",
     "exception": false,
     "start_time": "2023-12-10T23:32:23.771155",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "word_count <- reviews_unigram %>%\n",
    "    group_by(id) %>%\n",
    "    summarise(word_count = n(), .groups = \"drop\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fde41d75",
   "metadata": {
    "papermill": {
     "duration": 0.01977,
     "end_time": "2023-12-10T23:32:26.218027",
     "exception": false,
     "start_time": "2023-12-10T23:32:26.198257",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.2.2 Average sentence length\n",
    "As with word counts, the average sentence length can be interesting for our goal. Sentence length can indicate how consise customers are in their review. As word count indicates the total length of the review, average sentence length is more indicative within the review. Unsatisfied customers might write long sentences to show their dissatisfaction, while satisfied customers will describe the positive aspects more consise. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "id": "5e61376b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:26.306449Z",
     "iopub.status.busy": "2023-12-10T23:32:26.304683Z",
     "iopub.status.idle": "2023-12-10T23:32:38.166054Z",
     "shell.execute_reply": "2023-12-10T23:32:38.163835Z"
    },
    "papermill": {
     "duration": 11.930014,
     "end_time": "2023-12-10T23:32:38.169052",
     "exception": false,
     "start_time": "2023-12-10T23:32:26.239038",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "sent_len <- amazon %>%\n",
    "    unnest_tokens(token, review, token = \"sentences\") %>%\n",
    "    group_by(id) %>%\n",
    "    summarise(sent_len = token %>% nchar() %>% mean()) "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "96f1a1a9",
   "metadata": {
    "papermill": {
     "duration": 0.021261,
     "end_time": "2023-12-10T23:32:38.210170",
     "exception": false,
     "start_time": "2023-12-10T23:32:38.188909",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.2.3 Count of exclamation marks and question marks\n",
    "\n",
    "We expect reviews with more questionmarks to be indicative for less satisfied customers because they would ask for reasons why something is not working or express general confusion about the product.\n",
    "\n",
    "Regarding the count of exclamation points we expect more exclamation points to indicated lower satisfaction because it could represent angry or very expressive customers. However, one could argue that very expressive customers could also express high satisfaction using a lot of exclamation marks. But we expect this effect to be stronger for highly dissatisfied customers, especially because they would have a higher baserate of writing reviews."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 11,
   "id": "3ac69fe0",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:38.253868Z",
     "iopub.status.busy": "2023-12-10T23:32:38.251983Z",
     "iopub.status.idle": "2023-12-10T23:32:39.428421Z",
     "shell.execute_reply": "2023-12-10T23:32:39.426422Z"
    },
    "papermill": {
     "duration": 1.20109,
     "end_time": "2023-12-10T23:32:39.431161",
     "exception": false,
     "start_time": "2023-12-10T23:32:38.230071",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Count exclamation marks and question marks using str_count\n",
    "punctuation <- amazon %>%\n",
    "    mutate(excl_mark = str_count(review, \"!\"),\n",
    "           ques_mark = str_count(review, \"\\\\?\")) %>%\n",
    "    select(id, excl_mark, ques_mark)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "993f88d8",
   "metadata": {
    "_uuid": "d837bb3b5f81da05a9012fb9f945603e2d0dc08c",
    "papermill": {
     "duration": 0.019858,
     "end_time": "2023-12-10T23:32:39.470622",
     "exception": false,
     "start_time": "2023-12-10T23:32:39.450764",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.2.4 Stopwords\n",
    "\n",
    "Stopwords are often seen as unimportant and adviced to remove because of their high frequency and lack of variation across different texts. However, context matters and nothing should be done out of habit. Different contexts require different information, and for our goal stopwords might give us an insight about customers writing style and therefore clues to their satisfaction level of the product. \n",
    "\n",
    "Based on this we will not remove the stopwords but get the count of stopwords per review to use them for the prediction."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 12,
   "id": "3fe0d1be",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:39.515298Z",
     "iopub.status.busy": "2023-12-10T23:32:39.513439Z",
     "iopub.status.idle": "2023-12-10T23:32:48.054517Z",
     "shell.execute_reply": "2023-12-10T23:32:48.052393Z"
    },
    "papermill": {
     "duration": 8.566605,
     "end_time": "2023-12-10T23:32:48.057899",
     "exception": false,
     "start_time": "2023-12-10T23:32:39.491294",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "stopwords <- reviews_unigram %>% \n",
    "    # Keep only stopwords of review \n",
    "    inner_join(get_stopwords(), by = c(unigram = 'word')) %>% \n",
    "    # Compute total number of stopwords per review\n",
    "    group_by(id) %>% \n",
    "    summarise(n_stopwords = sum(n), .groups = \"drop\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "7a1f6d14",
   "metadata": {
    "papermill": {
     "duration": 0.020276,
     "end_time": "2023-12-10T23:32:48.098104",
     "exception": false,
     "start_time": "2023-12-10T23:32:48.077828",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.3 Prefiltering features\n",
    "\n",
    "In this section we will focus on filtering features that are based on the tf_idf metric because these account by far for the biggest amount of our large predictor set. \n",
    "\n",
    "### 4.3.1 Non-zero variance features\n",
    "\n",
    "We want to remove words that are very rare and only occur in a very small number of reviews; they may not provide meaningful information such as spelling mistakes.\n",
    "\n",
    "To do this, we'll calculate the \"surprise\" factor for each word. The surprise factor measures how unexpected or rare a word is in the reviews. So, we'll keep words that are less surprising or less rare than words that occur in only 0.01% of the reviews. This helps us remove uncommon and potentially irrelevant words from our analysis."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 13,
   "id": "20388be4",
   "metadata": {
    "_uuid": "b79ad69b3b2b29c4e87abec0f3f3dd8ba0023e89",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:48.141786Z",
     "iopub.status.busy": "2023-12-10T23:32:48.139993Z",
     "iopub.status.idle": "2023-12-10T23:32:53.678196Z",
     "shell.execute_reply": "2023-12-10T23:32:53.675967Z"
    },
    "papermill": {
     "duration": 5.563492,
     "end_time": "2023-12-10T23:32:53.681397",
     "exception": false,
     "start_time": "2023-12-10T23:32:48.117905",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Near-zero variance features of the if_idf features\n",
    "tf_idf_n_gram <- tf_idf_n_gram %>% filter(idf <= -log(0.01/100))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2a5b1d4a",
   "metadata": {
    "papermill": {
     "duration": 0.020517,
     "end_time": "2023-12-10T23:32:53.723700",
     "exception": false,
     "start_time": "2023-12-10T23:32:53.703183",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.3.2 Correlated and linear combinations of features \n",
    "\n",
    "As we are dealing with a large number of predictors, it is likely that features are correlated to each other. But as we have a large number of predictors it is computationally intensive to directly remove those features. Additionally it can lead to a loss of important information. \n",
    "\n",
    "As a result we will employ Lasso and Ridge regression to help with this problem.\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d36fd59d",
   "metadata": {
    "papermill": {
     "duration": 0.019868,
     "end_time": "2023-12-10T23:32:53.763516",
     "exception": false,
     "start_time": "2023-12-10T23:32:53.743648",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.4 Prepare data for modelling\n",
    "\n",
    "* First, in order to work with the data, we join the tf_idf features with the structural features in a **predictor data set**.   \n",
    "* Second, to save memory and computational resources when dealing with our large dataset we cast our data frame into a **sparse matrix**\n",
    "* Third, we **prepare the outcome variable** for the model fitting. Here, our outcome variable is a dichotomised version of the ordinal rating variable.\n",
    "\n",
    "### 4.4.1 Prepare predictor data set\n",
    "\n",
    "First, let's join the structural features together."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "id": "42a8c031",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:53.806988Z",
     "iopub.status.busy": "2023-12-10T23:32:53.805242Z",
     "iopub.status.idle": "2023-12-10T23:32:54.228955Z",
     "shell.execute_reply": "2023-12-10T23:32:54.226838Z"
    },
    "papermill": {
     "duration": 0.448364,
     "end_time": "2023-12-10T23:32:54.231787",
     "exception": false,
     "start_time": "2023-12-10T23:32:53.783423",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 6</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>id</th><th scope=col>word_count</th><th scope=col>sent_len</th><th scope=col>excl_mark</th><th scope=col>ques_mark</th><th scope=col>n_stopwords</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>1</td><td>66</td><td>158.3333</td><td>0</td><td>0</td><td>33</td></tr>\n",
       "\t<tr><td>2</td><td>26</td><td>182.0000</td><td>0</td><td>0</td><td>13</td></tr>\n",
       "\t<tr><td>3</td><td>29</td><td>181.0000</td><td>0</td><td>0</td><td>12</td></tr>\n",
       "\t<tr><td>4</td><td>61</td><td> 96.6000</td><td>0</td><td>0</td><td>45</td></tr>\n",
       "\t<tr><td>5</td><td>63</td><td>125.0000</td><td>5</td><td>0</td><td>43</td></tr>\n",
       "\t<tr><td>6</td><td>72</td><td>148.2500</td><td>0</td><td>0</td><td>49</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 6\n",
       "\\begin{tabular}{llllll}\n",
       " id & word\\_count & sent\\_len & excl\\_mark & ques\\_mark & n\\_stopwords\\\\\n",
       " <chr> & <int> & <dbl> & <int> & <int> & <int>\\\\\n",
       "\\hline\n",
       "\t 1 & 66 & 158.3333 & 0 & 0 & 33\\\\\n",
       "\t 2 & 26 & 182.0000 & 0 & 0 & 13\\\\\n",
       "\t 3 & 29 & 181.0000 & 0 & 0 & 12\\\\\n",
       "\t 4 & 61 &  96.6000 & 0 & 0 & 45\\\\\n",
       "\t 5 & 63 & 125.0000 & 5 & 0 & 43\\\\\n",
       "\t 6 & 72 & 148.2500 & 0 & 0 & 49\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 6\n",
       "\n",
       "| id &lt;chr&gt; | word_count &lt;int&gt; | sent_len &lt;dbl&gt; | excl_mark &lt;int&gt; | ques_mark &lt;int&gt; | n_stopwords &lt;int&gt; |\n",
       "|---|---|---|---|---|---|\n",
       "| 1 | 66 | 158.3333 | 0 | 0 | 33 |\n",
       "| 2 | 26 | 182.0000 | 0 | 0 | 13 |\n",
       "| 3 | 29 | 181.0000 | 0 | 0 | 12 |\n",
       "| 4 | 61 |  96.6000 | 0 | 0 | 45 |\n",
       "| 5 | 63 | 125.0000 | 5 | 0 | 43 |\n",
       "| 6 | 72 | 148.2500 | 0 | 0 | 49 |\n",
       "\n"
      ],
      "text/plain": [
       "  id word_count sent_len excl_mark ques_mark n_stopwords\n",
       "1 1  66         158.3333 0         0         33         \n",
       "2 2  26         182.0000 0         0         13         \n",
       "3 3  29         181.0000 0         0         12         \n",
       "4 4  61          96.6000 0         0         45         \n",
       "5 5  63         125.0000 5         0         43         \n",
       "6 6  72         148.2500 0         0         49         "
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
       "<ol class=list-inline><li>183531</li><li>6</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 183531\n",
       "\\item 6\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 183531\n",
       "2. 6\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 183531      6"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "structural_x <- \n",
    "    amazon %>% \n",
    "    select(id) %>%\n",
    "    left_join(word_count, by = \"id\") %>%\n",
    "    left_join(sent_len, by = \"id\") %>%\n",
    "    left_join(punctuation, by = \"id\") %>%\n",
    "    left_join(stopwords, by = \"id\")\n",
    "\n",
    "head(structural_x)\n",
    "dim(structural_x)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "05e066fe",
   "metadata": {
    "papermill": {
     "duration": 0.022386,
     "end_time": "2023-12-10T23:32:54.274604",
     "exception": false,
     "start_time": "2023-12-10T23:32:54.252218",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "Until now, our tf_idf data is in a long format, while our structual feature data is in a wide format.\n",
    "We first pivot the structual data into a long format before binding it to the tf_idf data because we use a long format data set for transforming it into a sparse matrix using the `cast_sparse` function."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "id": "471d0c25",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:54.320396Z",
     "iopub.status.busy": "2023-12-10T23:32:54.318636Z",
     "iopub.status.idle": "2023-12-10T23:32:54.405196Z",
     "shell.execute_reply": "2023-12-10T23:32:54.402593Z"
    },
    "papermill": {
     "duration": 0.113436,
     "end_time": "2023-12-10T23:32:54.408743",
     "exception": false,
     "start_time": "2023-12-10T23:32:54.295307",
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
       "<ol class=list-inline><li>917655</li><li>3</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 917655\n",
       "\\item 3\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 917655\n",
       "2. 3\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 917655      3"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 3</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>id</th><th scope=col>feature</th><th scope=col>value</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>1</td><td>word_count </td><td> 66.0000</td></tr>\n",
       "\t<tr><td>1</td><td>sent_len   </td><td>158.3333</td></tr>\n",
       "\t<tr><td>1</td><td>excl_mark  </td><td>  0.0000</td></tr>\n",
       "\t<tr><td>1</td><td>ques_mark  </td><td>  0.0000</td></tr>\n",
       "\t<tr><td>1</td><td>n_stopwords</td><td> 33.0000</td></tr>\n",
       "\t<tr><td>2</td><td>word_count </td><td> 26.0000</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 3\n",
       "\\begin{tabular}{lll}\n",
       " id & feature & value\\\\\n",
       " <chr> & <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t 1 & word\\_count  &  66.0000\\\\\n",
       "\t 1 & sent\\_len    & 158.3333\\\\\n",
       "\t 1 & excl\\_mark   &   0.0000\\\\\n",
       "\t 1 & ques\\_mark   &   0.0000\\\\\n",
       "\t 1 & n\\_stopwords &  33.0000\\\\\n",
       "\t 2 & word\\_count  &  26.0000\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 3\n",
       "\n",
       "| id &lt;chr&gt; | feature &lt;chr&gt; | value &lt;dbl&gt; |\n",
       "|---|---|---|\n",
       "| 1 | word_count  |  66.0000 |\n",
       "| 1 | sent_len    | 158.3333 |\n",
       "| 1 | excl_mark   |   0.0000 |\n",
       "| 1 | ques_mark   |   0.0000 |\n",
       "| 1 | n_stopwords |  33.0000 |\n",
       "| 2 | word_count  |  26.0000 |\n",
       "\n"
      ],
      "text/plain": [
       "  id feature     value   \n",
       "1 1  word_count   66.0000\n",
       "2 1  sent_len    158.3333\n",
       "3 1  excl_mark     0.0000\n",
       "4 1  ques_mark     0.0000\n",
       "5 1  n_stopwords  33.0000\n",
       "6 2  word_count   26.0000"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "structural_x <- structural_x %>% \n",
    "    pivot_longer(cols = -id, \n",
    "                 names_to = \"feature\", \n",
    "                 values_to = \"value\") %>%\n",
    "    mutate(value = replace_na(value, 0))\n",
    "\n",
    "dim(structural_x)\n",
    "head(structural_x)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "10b16350",
   "metadata": {
    "papermill": {
     "duration": 0.020675,
     "end_time": "2023-12-10T23:32:54.450045",
     "exception": false,
     "start_time": "2023-12-10T23:32:54.429370",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "Now, let's bind the structural data to the tf_idf data.\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 16,
   "id": "51aa1bab",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:32:54.495161Z",
     "iopub.status.busy": "2023-12-10T23:32:54.493252Z",
     "iopub.status.idle": "2023-12-10T23:33:15.239826Z",
     "shell.execute_reply": "2023-12-10T23:33:15.237570Z"
    },
    "papermill": {
     "duration": 20.77313,
     "end_time": "2023-12-10T23:33:15.243586",
     "exception": false,
     "start_time": "2023-12-10T23:32:54.470456",
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
       "<ol class=list-inline><li>31229666</li><li>3</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 31229666\n",
       "\\item 3\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 31229666\n",
       "2. 3\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 31229666        3"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A tibble: 6 × 3</caption>\n",
       "<thead>\n",
       "\t<tr><th scope=col>id</th><th scope=col>feature</th><th scope=col>value</th></tr>\n",
       "\t<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><td>1</td><td>word_count </td><td> 66.0000</td></tr>\n",
       "\t<tr><td>1</td><td>sent_len   </td><td>158.3333</td></tr>\n",
       "\t<tr><td>1</td><td>excl_mark  </td><td>  0.0000</td></tr>\n",
       "\t<tr><td>1</td><td>ques_mark  </td><td>  0.0000</td></tr>\n",
       "\t<tr><td>1</td><td>n_stopwords</td><td> 33.0000</td></tr>\n",
       "\t<tr><td>2</td><td>word_count </td><td> 26.0000</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A tibble: 6 × 3\n",
       "\\begin{tabular}{lll}\n",
       " id & feature & value\\\\\n",
       " <chr> & <chr> & <dbl>\\\\\n",
       "\\hline\n",
       "\t 1 & word\\_count  &  66.0000\\\\\n",
       "\t 1 & sent\\_len    & 158.3333\\\\\n",
       "\t 1 & excl\\_mark   &   0.0000\\\\\n",
       "\t 1 & ques\\_mark   &   0.0000\\\\\n",
       "\t 1 & n\\_stopwords &  33.0000\\\\\n",
       "\t 2 & word\\_count  &  26.0000\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A tibble: 6 × 3\n",
       "\n",
       "| id &lt;chr&gt; | feature &lt;chr&gt; | value &lt;dbl&gt; |\n",
       "|---|---|---|\n",
       "| 1 | word_count  |  66.0000 |\n",
       "| 1 | sent_len    | 158.3333 |\n",
       "| 1 | excl_mark   |   0.0000 |\n",
       "| 1 | ques_mark   |   0.0000 |\n",
       "| 1 | n_stopwords |  33.0000 |\n",
       "| 2 | word_count  |  26.0000 |\n",
       "\n"
      ],
      "text/plain": [
       "  id feature     value   \n",
       "1 1  word_count   66.0000\n",
       "2 1  sent_len    158.3333\n",
       "3 1  excl_mark     0.0000\n",
       "4 1  ques_mark     0.0000\n",
       "5 1  n_stopwords  33.0000\n",
       "6 2  word_count   26.0000"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "all_x <- rbind(\n",
    "        structural_x,\n",
    "        tf_idf_n_gram %>% \n",
    "            select(id, feature = n_gram, value = tf_idf) %>%\n",
    "            mutate(feature = paste0(\"tfidf_\", feature))\n",
    ") \n",
    "\n",
    "dim(all_x)\n",
    "head(all_x)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "cc93b82e",
   "metadata": {
    "papermill": {
     "duration": 0.021528,
     "end_time": "2023-12-10T23:33:15.293187",
     "exception": false,
     "start_time": "2023-12-10T23:33:15.271659",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.4.2 Cast into sparse matrix\n",
    "To save memory and computational resources when dealing with our large dataset we use a sparce matrix. Not all algorithms can work with sparse matrices. That is why we will use the `glmnet` package which is capable of working with sparse matrices and can be used for techniques such as Lasso and Ridge regression. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 17,
   "id": "494b575b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:33:15.339759Z",
     "iopub.status.busy": "2023-12-10T23:33:15.338045Z",
     "iopub.status.idle": "2023-12-10T23:33:35.301573Z",
     "shell.execute_reply": "2023-12-10T23:33:35.299605Z"
    },
    "papermill": {
     "duration": 19.990924,
     "end_time": "2023-12-10T23:33:35.305311",
     "exception": false,
     "start_time": "2023-12-10T23:33:15.314387",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "6 x 6 sparse Matrix of class \"dgCMatrix\"\n",
       "  word_count sent_len excl_mark ques_mark n_stopwords   tfidf_12\n",
       "1         66 158.3333         0         0          33 0.01551098\n",
       "2         26 182.0000         0         0          13 .         \n",
       "3         29 181.0000         0         0          12 .         \n",
       "4         61  96.6000         0         0          45 .         \n",
       "5         63 125.0000         5         0          43 .         \n",
       "6         72 148.2500         0         0          49 .         "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\n",
      "\n",
      "We have a sparse matrix containing 193748 features for 183531 reviews."
     ]
    }
   ],
   "source": [
    "# cast into sparse matrix\n",
    "all_x <- all_x %>%\n",
    "    cast_sparse(id, feature, value)\n",
    "\n",
    "# check results\n",
    "all_x[1:6, 1:6]\n",
    "\n",
    "cat(\"\\n\\nWe have a sparse matrix containing\", ncol(all_x), \"features for\", nrow(all_x), \"reviews.\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "26e821bd",
   "metadata": {
    "papermill": {
     "duration": 0.021701,
     "end_time": "2023-12-10T23:33:35.349922",
     "exception": false,
     "start_time": "2023-12-10T23:33:35.328221",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 4.4.3 Prepare response variable for `glmnet`\n",
    "\n",
    "The goal of this competition to predict wheter a customer is satisfied or not. A customer is satisfied when the `rating > 3`. Therefore, the outcome variable will be a factor that specifies whether this condition is met. \n",
    "\n",
    "Here, we choose ratings greater than 3, i.e. 4 and 5 to indicate satisfaction and ratings equal or lower than 3 to indicate dissatisfaction. Adding the cutoff of 3 to the dissatisfaction rather than the satisfaction level has been chosen because we expect rewiers who are only satisfied to a mediocre level to rather critize the certain aspects of the product instead of pointing out positive aspects."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 18,
   "id": "8d095fa6",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:33:35.397865Z",
     "iopub.status.busy": "2023-12-10T23:33:35.395719Z",
     "iopub.status.idle": "2023-12-10T23:33:35.585629Z",
     "shell.execute_reply": "2023-12-10T23:33:35.583621Z"
    },
    "papermill": {
     "duration": 0.217008,
     "end_time": "2023-12-10T23:33:35.588498",
     "exception": false,
     "start_time": "2023-12-10T23:33:35.371490",
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
       "<ol class=list-inline><li>FALSE</li><li>TRUE</li><li>&lt;NA&gt;</li><li>TRUE</li><li>&lt;NA&gt;</li><li>TRUE</li><li>TRUE</li><li>&lt;NA&gt;</li><li>TRUE</li><li>TRUE</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item FALSE\n",
       "\\item TRUE\n",
       "\\item <NA>\n",
       "\\item TRUE\n",
       "\\item <NA>\n",
       "\\item TRUE\n",
       "\\item TRUE\n",
       "\\item <NA>\n",
       "\\item TRUE\n",
       "\\item TRUE\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. FALSE\n",
       "2. TRUE\n",
       "3. &lt;NA&gt;\n",
       "4. TRUE\n",
       "5. &lt;NA&gt;\n",
       "6. TRUE\n",
       "7. TRUE\n",
       "8. &lt;NA&gt;\n",
       "9. TRUE\n",
       "10. TRUE\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       " [1] FALSE  TRUE    NA  TRUE    NA  TRUE  TRUE    NA  TRUE  TRUE"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "183531"
      ],
      "text/latex": [
       "183531"
      ],
      "text/markdown": [
       "183531"
      ],
      "text/plain": [
       "[1] 183531"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# creating response variable\n",
    "# The order of the cases in `X` may not be the same anymore as in amazon\n",
    "y <- data.frame(id = rownames(all_x)) %>%\n",
    "     inner_join(amazon, by = \"id\") %>% \n",
    "     # dichomotise rating variable\n",
    "     mutate(rating = case_when(rating > 3 ~ TRUE,\n",
    "                               rating <= 3 ~ FALSE)) %>%\n",
    "    \n",
    "     # Extract 'rating' as a factor\n",
    "     pull(rating)\n",
    "\n",
    "# check results\n",
    "head(y, 10)\n",
    "length(y)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ec8e8048",
   "metadata": {
    "_uuid": "5b5c79f14ac762022e5755d91264cbae0730b58b",
    "papermill": {
     "duration": 0.022227,
     "end_time": "2023-12-10T23:33:35.633057",
     "exception": false,
     "start_time": "2023-12-10T23:33:35.610830",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = models style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "5. Models\n",
    "</h1>\n",
    "\n",
    "## Not relying on manual feature selection\n",
    "To build a model using features you can experiment and try different features. However, with many features this process needs to be automated. There are several methods that eliminate the need for manual feature selection:\n",
    "- Lasso and Ridge regression can automatically choose important features while reducing redundancy.\n",
    "- Principal Components and Partial Least Squares regression are methods that handle many features while managing multicollinearity (correlations between features).\n",
    "- Smoothing adds flexibility to capture non-linear relationships without specifying exact mathematical forms.\n",
    "\n",
    "Each of these methods comes with a small set of parameters that control model flexibility. These parameters must be tuned for the best predictive performance. This tuning of the parameters is done using cross-validation. \n",
    "\n",
    "## 5.1 Model fitting\n",
    "For this competition we will be using Lasso and Ridge regression. These methods are suitable for scenarios where usual model fits show high variance, caused by the large amount of features. \n",
    "- Ridge regression: Shrinks the coefficients toward zero, though never actually zero, ensuring all variables remain in the model.\n",
    "- Lasso regression: Shrinks the coefficients, eventually pushing some to zero, removing them from the model.\n",
    "Consequently, Lasso models are simpler and more interpretable compared to Ridge models. \n",
    "\n",
    "**But** the performance of these methods depends on the underlying reltionships between features and the response variable. \n",
    "- If the response is influenced a little by many features, Ridge outperforms Lasso.\n",
    "- If the response is influenced strongly by a subset of features, Lasso outperforms Ridge. \n",
    "\n",
    "The features in our dataset consist of single words, word combinations (the bi-grams and tri-grams) and structural features. The Ridge might perform better on our data because of the many single word features that might not differ to much in their influence on Rating. On the other hand the Lasso might perform better because a subset of words, word combinations, or structural features might have significanlty more influence on the Rating. \n",
    "\n",
    "#### Split design matrix and target into training and test portions\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 19,
   "id": "7a2e5b43",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:33:35.682782Z",
     "iopub.status.busy": "2023-12-10T23:33:35.680988Z",
     "iopub.status.idle": "2023-12-10T23:33:36.694176Z",
     "shell.execute_reply": "2023-12-10T23:33:36.692116Z"
    },
    "papermill": {
     "duration": 1.040515,
     "end_time": "2023-12-10T23:33:36.697051",
     "exception": false,
     "start_time": "2023-12-10T23:33:35.656536",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "The number of training samples is 153531 \n",
      "The number of test samples is 30000 \n"
     ]
    }
   ],
   "source": [
    "# missing values in the ratings (here y) indentify reviews for the test portion.\n",
    "train_ids <- !is.na(y)\n",
    "\n",
    "cat(\"The number of training samples is\", sum(train_ids), \"\\n\")\n",
    "cat(\"The number of test samples is\", sum(is.na(y)), \"\\n\")\n",
    "\n",
    "# split both the X and Y in regard to the training IDs\n",
    "train_x <- all_x[train_ids == TRUE,]\n",
    "train_y <- y[train_ids == TRUE]\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "0895313b",
   "metadata": {
    "papermill": {
     "duration": 0.022469,
     "end_time": "2023-12-10T23:33:36.742205",
     "exception": false,
     "start_time": "2023-12-10T23:33:36.719736",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 5.1.2 Fitting cross validated lasso and ridge regression\n",
    "These regularization methods, Lasso and Ridge regression are very useful when dealing with high-dimensional data. A crucial aspect of effectively using them is determining the optimal values lambda. Lambda is know as a penalty parameter that determiines the trade-off between fitting the model to the training data and shrinking the model coefficients toward zero. To find the optimal lambda we use cross-validation to choose the value for which lambda results in the best model perfomance on unseen data.  \n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 20,
   "id": "0fbbc936",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:33:36.790777Z",
     "iopub.status.busy": "2023-12-10T23:33:36.788897Z",
     "iopub.status.idle": "2023-12-10T23:33:41.508822Z",
     "shell.execute_reply": "2023-12-10T23:33:41.506825Z"
    },
    "papermill": {
     "duration": 4.747227,
     "end_time": "2023-12-10T23:33:41.511745",
     "exception": false,
     "start_time": "2023-12-10T23:33:36.764518",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A matrix: 2 × 6 of type dbl</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>used</th><th scope=col>(Mb)</th><th scope=col>gc trigger</th><th scope=col>(Mb)</th><th scope=col>max used</th><th scope=col>(Mb)</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>Ncells</th><td> 10909112</td><td> 582.7</td><td>  28917357</td><td>1544.4</td><td>  70599014</td><td>3770.4</td></tr>\n",
       "\t<tr><th scope=row>Vcells</th><td>769206176</td><td>5868.6</td><td>1301627541</td><td>9930.7</td><td>1095602690</td><td>8358.8</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A matrix: 2 × 6 of type dbl\n",
       "\\begin{tabular}{r|llllll}\n",
       "  & used & (Mb) & gc trigger & (Mb) & max used & (Mb)\\\\\n",
       "\\hline\n",
       "\tNcells &  10909112 &  582.7 &   28917357 & 1544.4 &   70599014 & 3770.4\\\\\n",
       "\tVcells & 769206176 & 5868.6 & 1301627541 & 9930.7 & 1095602690 & 8358.8\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A matrix: 2 × 6 of type dbl\n",
       "\n",
       "| <!--/--> | used | (Mb) | gc trigger | (Mb) | max used | (Mb) |\n",
       "|---|---|---|---|---|---|---|\n",
       "| Ncells |  10909112 |  582.7 |   28917357 | 1544.4 |   70599014 | 3770.4 |\n",
       "| Vcells | 769206176 | 5868.6 | 1301627541 | 9930.7 | 1095602690 | 8358.8 |\n",
       "\n"
      ],
      "text/plain": [
       "       used      (Mb)   gc trigger (Mb)   max used   (Mb)  \n",
       "Ncells  10909112  582.7   28917357 1544.4   70599014 3770.4\n",
       "Vcells 769206176 5868.6 1301627541 9930.7 1095602690 8358.8"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Speed up process by using 4 cores\n",
    "doMC::registerDoMC(cores = 4)\n",
    "# Import garbage collector to create more memory\n",
    "gc(verbose = TRUE, full = TRUE)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "e7f12632",
   "metadata": {
    "papermill": {
     "duration": 0.024666,
     "end_time": "2023-12-10T23:33:41.559173",
     "exception": false,
     "start_time": "2023-12-10T23:33:41.534507",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### Cross validated full lasso regression\n",
    "We set `type.measure = \"AUC\"` to optimize the AUC through cross-validation as this is the evaluation metric for this competition."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 21,
   "id": "e1981188",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:33:41.609597Z",
     "iopub.status.busy": "2023-12-10T23:33:41.607681Z",
     "iopub.status.idle": "2023-12-10T23:37:11.489314Z",
     "shell.execute_reply": "2023-12-10T23:37:11.487164Z"
    },
    "papermill": {
     "duration": 209.910806,
     "end_time": "2023-12-10T23:37:11.493192",
     "exception": false,
     "start_time": "2023-12-10T23:33:41.582386",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:  glmnet::cv.glmnet(x = train_x, y = train_y, type.measure = \"auc\",      nfolds = 5, parallel = TRUE, family = \"binomial\", alpha = 1) \n",
       "\n",
       "Measure: AUC \n",
       "\n",
       "      Lambda Index Measure        SE Nonzero\n",
       "min 0.001374    95  0.9509 0.0003672    8854\n",
       "1se 0.001579    92  0.9507 0.0004204    7009"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\n",
      "\n",
      "This cross validated full lasso regression model yields the highest AUC of  0.951 (95 % CI: [ 0.951 : 0.951 ) \n",
      "when a regularization parameter of Lambda = 0.001 is used.\n",
      " The regularization results in 8854 non-zero coefficients\n",
      "\n",
      "This can also be seen in the following plot,\n",
      "where the AUC is highest for the corresponding log lambda on the x-axis"
     ]
    },
    {
     "data": {
      "image/png": "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\n6z/DgnFaFmvsiIiKkbOebERExK1GjQq5Ywec9/FhjR1ZKWt6FBv0ZdiAsGY7V0xpt2IKAJnS\nddXZC4f7NZw3NHB7x16tG3hGnzu8//gtlUPT/63oaulgiYioMso9TlZep47m9Gl5QoL+PUGA\nKGZ06FA7KChw2TJVZKTMyQldu2LuXNSsacmgiYxmTYmdXF1zW+TF75d9e/CfE4+VPi+89cnQ\nhh6jTh/Cs8O+3/dn5BEAqNPp+eX/+66do8rSwVoMa+yIiIqRp8bOzw/nzmHWLGzbhocPNdWr\np4wYAZnMc/hw/awoDx7g5k1xy5b4LVsymzUD50ChSs+aEjsAcrXP6GmzR+faonRstv6vi1/e\nunz1TlK1Gg0a+rtYLDgiIrI6Xl747ru4efMO//mnRqWyu3+/76RJeea6A4S0NOXkyQfmzdO9\n7Nq1q5eXl4XCJSqBlSV2RXH3b+Dub+kgKofw8PCQkJDQ0ND+/fubZ0ciImvn6ekZ1KOHRqOx\n//lnWa5p7fRE0fXatU4BAVo3N7lczjlQqDKTSGJHRERUZnmezxbB19YWnAOFKj2pJXaZyX/7\nNxgCIDY21pj2Go0mLCwsPT29mDY3b94EoNVqKyJAk2ONHRFRaYmiGBsbq9Fo7JycCl0pVlQo\n7gJidDRr7KiSk1piJ4qZ9+7dM779vn37BgwYYEzLqKiqO+kxEZG06eZAAaCws+vr7KxOThby\nToNyu0OHf86c0f3MGjuqzKSW2Kkc2hw9mn/K4mJ07959586dxd+xW7Fixf79+2vXrl3u6MyB\nNXZERKWVew6U5LVr3V57TZ6YmPNuRuvWipUrO9rbK27cUCYluWZlWS5SohJILbET5I7t27c3\nvr1cLg8JCSm+TVhYGACZzJomcyYiIuPlnwPl6aexZg3OnoW9Pbp0UQ8d6hsejokTcfOmvs1z\nz2HpUvjmX9OSyOKsNbF7GBt1+fLVuAfJqU/SFTb2zm7V6zdsVMebc52wxo6IqNycnMQpU3RV\ndwBsNm/2GD48T4Nt27JPn763e7eoVrPqjioVK0vsRM2jzYvmLF2z4ciluILvVm/YYfjYyR9M\nft5FwS8YERGVXU7VHYDuc+dCFPMtPqa4cSN24cKobt3AqjuqTKwpsdNk3v2/toE/nr0vV7q2\n7zGgeaO63u4uarUiOyMjKfHerasXjhz6Z+G0F3/Y8NuZiB98VFX0ySlr7IiIyi931Z37tWuF\n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\nRLRmd7QFAAAAAElFTkSuQmCC"
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
    "fit_cv_lasso <- glmnet::cv.glmnet(\n",
    "    train_x, \n",
    "    train_y, \n",
    "    family = \"binomial\",\n",
    "    parallel = TRUE, \n",
    "    type.measure = \"auc\",  # our final evaluation measure\n",
    "    alpha = 1,  # for a full lasso\n",
    "    nfolds = 5) \n",
    "\n",
    "cv_lasso_auc <- fit_cv_lasso$cvm[fit_cv_lasso$lambda == fit_cv_lasso$lambda.min]\n",
    "cv_lasso_lo <- fit_cv_lasso$cvlo[fit_cv_lasso$lambda == fit_cv_lasso$lambda.min]\n",
    "cv_lasso_up <- fit_cv_lasso$cvup[fit_cv_lasso$lambda == fit_cv_lasso$lambda.min]\n",
    "cv_lasso_nzero <- fit_cv_lasso$nzero[fit_cv_lasso$lambda == fit_cv_lasso$lambda.min]\n",
    "\n",
    "fit_cv_lasso\n",
    "\n",
    "cat(\"\\n\\nThis cross validated full lasso regression model yields the highest AUC of \", round(cv_lasso_auc, 3), \n",
    "    \"(95 % CI: [\", round(cv_lasso_lo, 3), \":\", round(cv_lasso_up, 3), \")\", \n",
    "    \"\\nwhen a regularization parameter of Lambda =\", round(fit_cv_lasso$lambda.min, 3), \"is used.\\n\",\n",
    "    \"The regularization results in\", cv_lasso_nzero, \"non-zero coefficients\")\n",
    "\n",
    "cat(\"\\n\\nThis can also be seen in the following plot,\\nwhere the AUC is highest for the corresponding log lambda on the x-axis\")\n",
    "plot(fit_cv_lasso)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "77842000",
   "metadata": {
    "papermill": {
     "duration": 0.023464,
     "end_time": "2023-12-10T23:37:11.544977",
     "exception": false,
     "start_time": "2023-12-10T23:37:11.521513",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### Cross validated full ridge regression\n",
    "We set `type.measure = \"AUC\"` to optimize the AUC through cross-validation as this is the evaluation metric for this competition."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 22,
   "id": "95529dc5",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:37:11.596414Z",
     "iopub.status.busy": "2023-12-10T23:37:11.594508Z",
     "iopub.status.idle": "2023-12-10T23:48:05.812168Z",
     "shell.execute_reply": "2023-12-10T23:48:05.809848Z"
    },
    "papermill": {
     "duration": 654.246939,
     "end_time": "2023-12-10T23:48:05.815256",
     "exception": false,
     "start_time": "2023-12-10T23:37:11.568317",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:  glmnet::cv.glmnet(x = train_x, y = train_y, type.measure = \"auc\",      nfolds = 5, parallel = TRUE, family = \"binomial\", alpha = 0) \n",
       "\n",
       "Measure: AUC \n",
       "\n",
       "    Lambda Index Measure        SE Nonzero\n",
       "min  1.089   100  0.9504 0.0003980  193748\n",
       "1se  1.439    94  0.9501 0.0004014  193748"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\n",
      "\n",
      "This cross validated full ridge regression model yields the highest AUC of  0.95 (95 % CI: [ 0.95 : 0.951 ) \n",
      "when a regularization parameter of Lambda = 1.089 is used.\n",
      "\n",
      "\n",
      "This can also be seen in the following plot,\n",
      "where the AUC is highest for the corresponding log lambda on the x-axisn.\n",
      " On the top x axis you can see the number of predictors used for each model at each regularization parameter value.\n",
      " As ridge regression doe only set coefficients very low but not to zero, this value is always the same."
     ]
    },
    {
     "data": {
      "image/png": "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\n2MXGxopIbGzs9Z8qj7/pVUhN9fkyOVk3btQ///QGx4QE/fZbffddjY/XCxdUVc+d0wkT9LHH\ntHdvnT5d09I0KUnHjNHbbtNy5bR1a507V1NT9Z13PKHQZtP69fWXX3TKFC1UyJsz/vMf/fhj\njYryiTKtWmmxYj6ZxmbzBNCM4SYoKKsklHXLv/Zhs3kiXcZHoUKef4L0sBgRoa++6vlXcD+K\nFNGvvtKZMz0LvSJaubJ+/bWq6tdfa5cuettt+vDD+tNPnjmzdKm+955+9JFu2uSdWklJum+f\nmvtrFQBLysvBjosnkNuCfCdhSIjUquXTEhkpHTv6tOTPL/37+7Q4HPL88/7Xrg4cKAMHypEj\nkj+/FCggItKsmdx/v/z2mxw5IjVqSN26YrPJfffJ55/Ln39KdLTceae0aiUJCTJ6tCxaJKdO\nSa1a8n//J3XqyIgRMmmSpKSIiDRuLOPHy+zZ8u673ptztGght94qb74pTqf3qpemTWXlSm/9\nnPsimPBwSUrKZKtny180rSoXL/o3JiR4/pJ+Qcn58/LSSz5Fn6dOSZcu4nJ5G3fvls6dpXZt\n2bjRUyq6cqXMmCE9esihQ7Jokecwm0169JCBA+WFF2ThQnG5JCxMnnhCRo2S48fl7bdl40aJ\niJBmzWTgQMmfX/btk59/luPHpWpViYnxXFCSlia7d0t0tERHGzMuAJBzcjtZBoB/9UexyCgl\nRbdt8/kccNcunT5dJ03S5cs9LRs36jPPaNu2+t//6oIFqqrr1mlMjBYooGFheuutunChbtig\njRp5l6Nq1NBvvtG6dX3WsWrV0gYNPOtY6X+6Fw79yhAls49K/w3LhNn/HkNC/A8uV06Dgz0n\ncQ9j6dI6YIBPeWjFivq//+nQoRoW5mmpXVsXL9azZ/Xll7VpU73pJr3/fl21SlX17Fn97DMd\nOlTHjdM///RMhtRU3bpVV6/WxEQz5ykAo7FiB1hCcLBUrerTUrGiVKzo01Krlowb59Ny880S\nFyciPgtOK1fK9u2eDYpvukkcDunYUb7+WtasEVWpX18eeEBUZfJkmT1bdu+WypXl4Yfl0Udl\n3Dh59VU5f15EpFAhGTNGEhJk2DDvTs5RUfLII977/Lpv+Fa4sFy8KMnJPouCISGSmpqtTXPy\npux3zL3OmtG+fd7bJbvPc/Cg/91Q9u6VNm089252+/NPufNOiY72bGqtKlu3ytdfyxNPSGys\n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"
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
    "fit_cv_ridge <- glmnet::cv.glmnet(\n",
    "    train_x, \n",
    "    train_y, \n",
    "    family = \"binomial\",\n",
    "    parallel = TRUE, \n",
    "    type.measure = \"auc\",  # our final evaluation measure\n",
    "    alpha = 0,  # for a full ridge\n",
    "    nfolds = 5\n",
    ")\n",
    "\n",
    "cv_ridge_auc <- fit_cv_ridge$cvm[fit_cv_ridge$lambda == fit_cv_ridge$lambda.min]\n",
    "cv_ridge_lo <- fit_cv_ridge$cvlo[fit_cv_ridge$lambda == fit_cv_ridge$lambda.min]\n",
    "cv_ridge_up <- fit_cv_ridge$cvup[fit_cv_ridge$lambda == fit_cv_ridge$lambda.min]\n",
    "cv_ridge_nzero <- fit_cv_ridge$nzero[fit_cv_ridge$lambda == fit_cv_ridge$lambda.min]\n",
    "\n",
    "fit_cv_ridge\n",
    "\n",
    "cat(\"\\n\\nThis cross validated full ridge regression model yields the highest AUC of \", round(cv_ridge_auc, 3), \n",
    "    \"(95 % CI: [\", round(cv_ridge_lo, 3), \":\", round(cv_ridge_up, 3), \")\", \n",
    "    \"\\nwhen a regularization parameter of Lambda =\", round(fit_cv_ridge$lambda.min, 3), \"is used.\\n\")\n",
    "\n",
    "cat(\"\\n\\nThis can also be seen in the following plot,\\nwhere the AUC is highest for the corresponding log lambda on the x-axisn.\\n\",\n",
    "   \"On the top x axis you can see the number of predictors used for each model at each regularization parameter value.\\n\",\n",
    "   \"As ridge regression doe only set coefficients very low but not to zero, this value is always the same.\")\n",
    "plot(fit_cv_ridge)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d87dbaca",
   "metadata": {
    "papermill": {
     "duration": 0.026339,
     "end_time": "2023-12-10T23:48:05.867262",
     "exception": false,
     "start_time": "2023-12-10T23:48:05.840923",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "# 5.2 Model evaluation\n",
    "To evaluate the performance of the models we asses their quality using the Area under the Curve (AUC) which summarizes the Receiver Operating Characteristics (ROC) in a single value. It is a measure of accuracy that generalized over all possible classification thresholds and is therefore."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a335c4ba",
   "metadata": {
    "papermill": {
     "duration": 0.025237,
     "end_time": "2023-12-10T23:48:05.917582",
     "exception": false,
     "start_time": "2023-12-10T23:48:05.892345",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 5.2.1 AUC"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 23,
   "id": "edc35200",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:05.972349Z",
     "iopub.status.busy": "2023-12-10T23:48:05.970385Z",
     "iopub.status.idle": "2023-12-10T23:48:05.997405Z",
     "shell.execute_reply": "2023-12-10T23:48:05.995271Z"
    },
    "papermill": {
     "duration": 0.058177,
     "end_time": "2023-12-10T23:48:06.000431",
     "exception": false,
     "start_time": "2023-12-10T23:48:05.942254",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "AUC for CV full Lasso Regression: 0.9509 \n",
      "AUC for CV full Ridge Regression: 0.9504 \n"
     ]
    }
   ],
   "source": [
    "cv_lasso_auc <- fit_cv_lasso$cvm[fit_cv_lasso$lambda == fit_cv_lasso$lambda.min]\n",
    "cv_ridge_auc <- fit_cv_ridge$cvm[fit_cv_ridge$lambda == fit_cv_ridge$lambda.min]\n",
    "\n",
    "cat(\"AUC for CV full Lasso Regression:\", round(cv_lasso_auc, 4), \"\\n\")\n",
    "cat(\"AUC for CV full Ridge Regression:\", round(cv_ridge_auc, 4), \"\\n\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "eee31b89",
   "metadata": {
    "papermill": {
     "duration": 0.025734,
     "end_time": "2023-12-10T23:48:06.051134",
     "exception": false,
     "start_time": "2023-12-10T23:48:06.025400",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "**Conclusion**: Both AUC values for the CV ridge and the CV lasso regression are very high and their 95% confidence intervals obtained by cross-validation are very narrow and overlap (see previous section for details). Since the lasso regression is generally a simpler model, we choose this model to predict ratings on or test data.\n",
    "Also, starting with 193748 predictors, our lasso regression model uses **only 8220 predictors** and sets the rest of the predictors coefficients to zero."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "cc1d318e",
   "metadata": {
    "papermill": {
     "duration": 0.02591,
     "end_time": "2023-12-10T23:48:06.102412",
     "exception": false,
     "start_time": "2023-12-10T23:48:06.076502",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 5.2.2 ROC Curves"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a03f430b",
   "metadata": {
    "papermill": {
     "duration": 0.024751,
     "end_time": "2023-12-10T23:48:06.152298",
     "exception": false,
     "start_time": "2023-12-10T23:48:06.127547",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "In this section, we aimed at displaying the ROC curves of our two models in order to visualize the difference.\n",
    "However, our code returns different AUC values and we did not enough time to figure out the reason.\n",
    "Hence, the results of this section will not be interpreted until we figure out the problem."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 24,
   "id": "06e02333",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:06.213303Z",
     "iopub.status.busy": "2023-12-10T23:48:06.211189Z",
     "iopub.status.idle": "2023-12-10T23:48:07.913653Z",
     "shell.execute_reply": "2023-12-10T23:48:07.911421Z"
    },
    "papermill": {
     "duration": 1.736806,
     "end_time": "2023-12-10T23:48:07.916704",
     "exception": false,
     "start_time": "2023-12-10T23:48:06.179898",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# CV LASSO\n",
    "pred_cv_lasso <- predict(fit_cv_lasso, \n",
    "                         newx = train_x,\n",
    "                         s = fit_cv_lasso$lambda.min, \n",
    "                         type = 'response')\n",
    "\n",
    "\n",
    "# CV RIDGE\n",
    "pred_cv_ridge <- predict(fit_cv_ridge, \n",
    "                         newx = train_x,\n",
    "                         s = fit_cv_ridge$lambda.min, \n",
    "                         type = 'response')"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 25,
   "id": "2908319b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:07.972296Z",
     "iopub.status.busy": "2023-12-10T23:48:07.970349Z",
     "iopub.status.idle": "2023-12-10T23:48:08.886806Z",
     "shell.execute_reply": "2023-12-10T23:48:08.884704Z"
    },
    "papermill": {
     "duration": 0.947006,
     "end_time": "2023-12-10T23:48:08.889907",
     "exception": false,
     "start_time": "2023-12-10T23:48:07.942901",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "AUC for Lasso: 0.9770464 \n",
      "AUC for Ridge: 0.9902048 \n"
     ]
    },
    {
     "data": {
      "image/png": "iVBORw0KGgoAAAANSUhEUgAAA0gAAANICAIAAAByhViMAAAABmJLR0QA/wD/AP+gvaeTAAAg\nAElEQVR4nOzdd3hU1cLF4d9Mem9A6CAdFZBLU4oUkfqBDUEpYkGwXEWvWK5cBHsXG2AvYAEF\nEURQREDpIiIgvSMlvfdkZr4/JlJDSCDJnpms9/HxSWbOnFmCSVb2OXtvi8PhQERERETcn9V0\nABEREREpGyp2IiIiIh5CxU5ERETEQ6jYiYiIiHgIFTsRERERD6FiJyIiIuIhVOxEREREPISK\nnYiIiIiHULETERER8RAqdiIiIiIeQsVORERExEOo2ImIiIh4CBU7EREREQ+hYiciIiLiIVTs\nRERERDyEip2IiIiIh1CxExEREfEQKnYiIiIiHkLFTkRERMRDqNiJiIiIeAgVOxEREREPoWIn\nIiIi4iFU7EREREQ8hIqdiIiIiIdQsRMRERHxECp2IiIiIh5CxU5ERETEQ6jYiYiIiHgIFTsR\nERERD6FiJyIiIuIhVOxEREREPISKnYiIiIiHULETERER8RAqdiIiIiIeQsVORERExEOo2ImI\niIh4CBU7EREREQ+hYiciIiLiIVTsRERERDyEip2IiIiIh1CxExEREfEQKnYiIiIiHkLFTkRE\nRMRDqNiJiIiIeAgVOxEREREPoWInIiIi4iFU7EREREQ8hIqdiIiIiIdQsRMRERHxECp2IiIi\nIh5CxU5ERETEQ6jYiYiIiHgIFTsRERERD6FiJyIiIuIhVOxEREREPISKnYiIiIiHULETERER\n8RAqdiIiIiIeQsVORERExEOo2ImIiIh4CBU7EREREQ+hYiciIiLiIVTsRERERDyEip2IiIiI\nh1CxExEREfEQKnYiIiIiHkLFTkRERMRDqNiJiIiIeAgVOxEREREPoWInIiIi4iFU7EREREQ8\nhIqdiIiIiIdQsRMRERHxECp2IiIiIh5CxU5ERETEQ6jYiYiIiHgIFTsRERERD6FiJyIiIuIh\nVOxEREREPISKnYiIiIiHULETERER8RAqdiIiIiIeQsVORERExEOo2ImIiIh4CBU7EREREQ+h\nYiciIiLiIVTsRERERDyEip2IiIiIh1CxExEREfEQKnYiIiIiHkLFTkRERMRDqNiJiIiIeAgV\nOxEREREPoWInIiIi4iFU7EREREQ8hIqdiIiIiIfwNh3ADaSmpn766afZ2dmmg4iIiIhLCAgI\n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"
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
    "# Lasso prediction performances on training data\n",
    "prediction_cv_lasso <- prediction(pred_cv_lasso[,1], train_y)\n",
    "perf_cv_lasso <- performance(prediction_cv_lasso, 'tpr', 'fpr')\n",
    "\n",
    "# Ridge prediction performances on training data\n",
    "prediction_cv_ridge <- prediction(pred_cv_ridge[,1], train_y)\n",
    "perf_cv_ridge <- performance(prediction_cv_ridge, 'tpr', 'fpr')\n",
    "\n",
    "# AUC\n",
    "cat(\"AUC for Lasso:\", performance(prediction_cv_lasso, 'auc')@y.values[[1]], \"\\n\")\n",
    "cat(\"AUC for Ridge:\", performance(prediction_cv_ridge, 'auc')@y.values[[1]], \"\\n\")\n",
    "\n",
    "#plot ROC curve for Lasso and Ridge\n",
    "plot(perf_cv_lasso, col=\"green\", )\n",
    "lines(perf_cv_ridge@x.values[[1]], perf_cv_ridge@y.values[[1]], col = \"blue\")\n",
    "lines(c(0,1),c(0,1),col = \"red\", lty = 4 )"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2b84fb09",
   "metadata": {
    "papermill": {
     "duration": 0.02661,
     "end_time": "2023-12-10T23:48:08.942725",
     "exception": false,
     "start_time": "2023-12-10T23:48:08.916115",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 5.2.3 Other Performance Measures\n",
    "\n",
    "Here we take a look at other performance measures, namely the sensitivity, the specificity and the accuracy.\n",
    "These measures are not too relevant for the question at hand because they are specific to a classification threshold.\n",
    "\n",
    "Here we exemplary look at their values for a given threshold of .5."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 26,
   "id": "85722e8c",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:09.000991Z",
     "iopub.status.busy": "2023-12-10T23:48:08.998739Z",
     "iopub.status.idle": "2023-12-10T23:48:09.105116Z",
     "shell.execute_reply": "2023-12-10T23:48:09.102836Z"
    },
    "papermill": {
     "duration": 0.139056,
     "end_time": "2023-12-10T23:48:09.108169",
     "exception": false,
     "start_time": "2023-12-10T23:48:08.969113",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "cutoff <- 0.5\n",
    "# CV LASSO\n",
    "pred_cv_lasso2 <- factor(ifelse(pred_cv_lasso >= cutoff, TRUE, FALSE))\n",
    "# CV RIDGE\n",
    "pred_cv_ridge2 <- factor(ifelse(pred_cv_ridge >= cutoff, TRUE, FALSE))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "5f9008ee",
   "metadata": {
    "papermill": {
     "duration": 0.026715,
     "end_time": "2023-12-10T23:48:09.162654",
     "exception": false,
     "start_time": "2023-12-10T23:48:09.135939",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### Confusion Matrix"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "id": "196ac039",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:09.221183Z",
     "iopub.status.busy": "2023-12-10T23:48:09.219314Z",
     "iopub.status.idle": "2023-12-10T23:48:10.427775Z",
     "shell.execute_reply": "2023-12-10T23:48:10.425714Z"
    },
    "papermill": {
     "duration": 1.24082,
     "end_time": "2023-12-10T23:48:10.430509",
     "exception": false,
     "start_time": "2023-12-10T23:48:09.189689",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "##### Confusion Matrix for CV Lasso Regression\n"
     ]
    },
    {
     "data": {
      "text/plain": [
       "          Reference\n",
       "Prediction  FALSE   TRUE\n",
       "     FALSE  28492   2493\n",
       "     TRUE    7701 114845"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "\n",
      "\n",
      "##### Confusion Matrix for CV Ridge Regression\n"
     ]
    },
    {
     "data": {
      "text/plain": [
       "          Reference\n",
       "Prediction  FALSE   TRUE\n",
       "     FALSE  25341    461\n",
       "     TRUE   10852 116877"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Confusion matrix\n",
    "lasso_cm <- caret::confusionMatrix(pred_cv_lasso2, factor(train_y))\n",
    "ridge_cm <- caret::confusionMatrix(pred_cv_ridge2, factor(train_y))\n",
    "\n",
    "cat(\"##### Confusion Matrix for CV Lasso Regression\\n\")\n",
    "lasso_cm$table\n",
    "cat(\"\\n\\n\")\n",
    "cat(\"##### Confusion Matrix for CV Ridge Regression\\n\")\n",
    "ridge_cm$table"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "40d11fae",
   "metadata": {
    "papermill": {
     "duration": 0.026651,
     "end_time": "2023-12-10T23:48:10.483894",
     "exception": false,
     "start_time": "2023-12-10T23:48:10.457243",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### Performance Measures"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 28,
   "id": "bc8e8a55",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:10.541190Z",
     "iopub.status.busy": "2023-12-10T23:48:10.539350Z",
     "iopub.status.idle": "2023-12-10T23:48:11.124240Z",
     "shell.execute_reply": "2023-12-10T23:48:11.120756Z"
    },
    "papermill": {
     "duration": 0.617215,
     "end_time": "2023-12-10T23:48:11.127685",
     "exception": false,
     "start_time": "2023-12-10T23:48:10.510470",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "image/png": "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\nLKx+iJ81jGqFXbEAAACKqJwtdt78NUNHPG4YRlhM788+vLdSlgkAAIAzUjlb7A79b5ZhGCLi\nzlmyKMddKcsEAADAGamcsPv06wMi0rtTDRH58vN9lbJMAAAAnJFKCDtX1ndLc9xhMT3vuGOw\niBz56YNq8sXFuicz2FMAAACoOpVwjN3u2d+KSMOh14fXSG4f+cGf+eu/PFo4JNFRfIxhuH7/\n6uN5C3/fk5Kh2WMat+p41XU3dW8cU/4xG54a9/Dy1FvemzM44e/vGM0//PLw2346b+iL025q\nIiK7Z989cfauCR981unQ4udfn7P5YMaXX38tIro37X+fzln8x58HUjLduiWuZp3WHS+64abB\ndcPM5Vl7yq+Pjn9uXYOBz78ytmnxCS+YOPLN3TnD3/7khtonPFkAAICgCHiLneF/d8kRTTOP\nuTRJRBvRr46I/DBr5wlDDPd7j94+9b2vtqW66zVrVz/BtmHZj8/cO2b2mowzGlNOBUd+uvOR\nN/brsR279RARw5f51D8mvDnn+90ZpvOat2vbvJFk7v953sx7Jrzk/WvTYulrr9l5lFnTUn6e\nW3wtuidl5t5cq6PldVQdAACoHgLdYpd/+OPtTl9U/ZuaOywi0mDIYPlq2tHlM7zGNOtf11nc\n+8XjX63PiG879IVJIxMsmojs++ODfz419/PnXvi/j5+yaOUdU05fTXqn5x3P3H5pi6Lfpq15\neUVKYVzzoa8/PTLCrImI7s18+dbbF6X8Mi/jH0NqhJe9dnuTa2qGf3502dJcz4XRtqLFpq+d\n7tSN5ItHl5LGbnelnUfi8/lExDCMSlxmsOi67vP5Qv2JFL0iIuJ2u7XSv9C72vP7/Qr81dJ1\nvegHj8fj9/uDO5kA+Xw+XddD/RUpOqNORLxeb3BnEjiv16vAKyJ/vSiV8g6saZrNZquMSaGS\nBRp2m99dIiJtx/Yp+m1YbN+eMW/+lrNn1sG8m+tHiYiI/sqcrZrZ8Z9HRiT8FWgNut50Y+3/\nfXBk47JcT68YW/nGlJcvceTxqhMRf26DXr0imo0cWlR1ImKyxg/onrho3r6DHn85Z9j3uvM+\nf3XTl4uOXDi4QdGA32ZuFZFB1zUsZSZ5eXnln3Z5GIZR6csMCpfL5XK5gj2LypGfnx/sKVQO\nj8cT7ClUjsLCwmBPoXKo8Y9dFPr3rswr4vF4Av/3bjKZ4uPjK2U+qFwBhZ3hz397XYbJEndb\n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\nQRDsAAAADIJgBwAAYBAEOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCIIdAACAQRDs\nAAAADIJgBwAAYBAEOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCIIdAACAQRDsAAAA\nDIJgBwAAYBAEOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCIIdAACAQRDsAAAADIJg\nBwAAYBAEOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCIIdAACAQRDsAAAADIJgBwAA\nYBAEOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCIIdAACAQRDsAAAADIJgBwAAYBAE\nOwAAAIMg2AEAABgEwQ4AAMAgCHYAAAAGQbADAAAwCEXX9WC3AUXzer1er1dRlLCwsGC3paTc\nbrfZbDabzcFuSImoqurxeETEbrcHuy0l5fF4FEWxWCzBbkiJ6LrucrlExGazmUyh/ZPV6/Xq\num61WoPdkJJyOp0iYrVaDTDevV6vAb5+XS6XrusWiyXUxzsugmAHAABgEKH9uxYAAADnEOwA\nAAAMgmAHAABgEAQ7AAAAgyDYAQAAGATBDgAAwCAIdgAAAAbBFIXBcXLHj/9esGTTjgMOCa/R\noEX3Pvfd2DCxVNbyr2b4129bly367Pufdv6Vlu3UYytWa3ntjf36dU20/P17aeXQgS/vzyy4\nYouxc8a3YrtcjB9bpJi9zRjxz6X2W0pKykVebfP6f56vHSOMkdLw4bjnUhsMfrpPreIszH7E\n8Ah2QXBszb8fmfypKlKtXqNqkrVt00/TNq068Mw7g9pVLOFa/tUM//pt6fTh05fuVRRzjfqN\napsde3ftW7po988/bZz61vPVbGfm2d+U6VIUc2xsdL51o6wcLL8Y/7ZIcXqbMeIfP/otLi6u\n0HJ3VkaOqsed3SiMkRJyZ675+NctybGO4izMfqRc0BFYquvwI3f1TOlx15Lfj/tKjv/+vzt7\npPS865EjLrUka/lXM/zrt5Pb3u7evXvPu/+5en+Wr8Rz+sC7z97bvXv3h15aeW6xQb163Nlv\nwmVtv/H4/T+5yN5mjPinFPvN69j98J09B4z4QDtbwhgpiZy0HdOG9uvevfsj07YVuTD7kXKC\nn0SBdmzNW6kutfL1z3RveubIdmLTlGevq6S6UmesPVaStfyrGf712++zfxaR5sOeu7ZmlK/E\n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\nYII="
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
    "# AUC\n",
    "ridge_auc <- fit_cv_ridge$cvm %>% max()\n",
    "lasso_auc <- fit_cv_lasso$cvm %>% max()\n",
    "\n",
    "# Accuracy\n",
    "ridge_accuracy <- (pred_cv_lasso2 == train_y) %>% mean()\n",
    "lasso_accuracy <- (pred_cv_lasso2 == train_y) %>% mean()\n",
    "\n",
    "lasso_metrics <- \n",
    "    lasso_cm$byClass %>% \n",
    "    enframe() %>%\n",
    "    rename(metric = name) %>%\n",
    "    add_row(metric = \"AUC\", value =  lasso_auc) %>%\n",
    "    add_row(metric = \"Accuracy\", value =  lasso_accuracy) \n",
    "\n",
    "ridge_metrics <- \n",
    "    ridge_cm$byClass %>% \n",
    "    enframe() %>%\n",
    "    rename(metric = name) %>%\n",
    "    add_row(metric = \"AUC\", value =  ridge_auc) %>%\n",
    "    add_row(metric = \"Accuracy\", value =  ridge_accuracy)\n",
    "    \n",
    "models_summary <- bind_rows(\n",
    "    lasso_metrics %>% filter(metric %in% c(\"Accuracy\", \"Sensitivity\", \"Specificity\")),\n",
    "    ridge_metrics %>% filter(metric %in% c(\"Accuracy\", \"Sensitivity\", \"Specificity\")),\n",
    "    ) %>% \n",
    "    add_column(model = rep(c(\"lasso\",\"ridge\"), each = 3))\n",
    "\n",
    "\n",
    "models_summary %>% \n",
    "    ggplot(aes(x = fct_rev(metric),\n",
    "               y = value,\n",
    "               color = model,\n",
    "               group = model)) +\n",
    "    geom_point(size = 3, position = position_dodge(width = .3)) +\n",
    "    geom_linerange(aes(xmin = metric, xmax = metric, ymin = value, ymax = 0),\n",
    "                 position = position_dodge(.3),\n",
    "                 show.legend = FALSE\n",
    "                ) +\n",
    "    coord_flip() +\n",
    "    theme_minimal() + \n",
    "    theme(text = element_text(size = 16),\n",
    "          axis.title.y = element_blank()) +\n",
    "    guides(color = guide_legend(reverse = TRUE))"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "cccbeef1",
   "metadata": {
    "papermill": {
     "duration": 0.02837,
     "end_time": "2023-12-10T23:48:11.183324",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.154954",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 5.2.4 Conclusion to Model Selection\n",
    "As described in section 5.2.1 both of our models yielded high and comparable AUC values of `.95` with very narrow 95 % confidence intervals obtained by 5 fold cross-validation. We favored the **lasso regression model** over the ridge regression model beacuse the lasso regression is a less flexible model by setting predictor coefficients to zero. Starting off with 193748 predictors, our lasso regression model uses **only 8220 predictors** and sets the rest of the predictors coefficients to zero. This will allow us to prevent overfitting."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "425aaf06",
   "metadata": {
    "_uuid": "db4164fa915f86b512ba3a4a576683dcf4b48320",
    "papermill": {
     "duration": 0.02824,
     "end_time": "2023-12-10T23:48:11.238846",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.210606",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = prediction_test style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    " 6. Prediction on the Test Data, Submission, & Conclusion\n",
    "</h1>\n",
    "After predicting the test data ratings, we need to bring the prediction in the right format for the competition submission."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c3fc5f08",
   "metadata": {
    "papermill": {
     "duration": 0.027223,
     "end_time": "2023-12-10T23:48:11.293591",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.266368",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.1 Predict Ratings of the Test Data\n",
    "\n",
    "Since our model evaluation returned the best AUC for the cross validated lasso regression model, \n",
    "we use this model to predict the ratings on the test data."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 29,
   "id": "42f49878",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:11.352162Z",
     "iopub.status.busy": "2023-12-10T23:48:11.350261Z",
     "iopub.status.idle": "2023-12-10T23:48:11.795549Z",
     "shell.execute_reply": "2023-12-10T23:48:11.793432Z"
    },
    "papermill": {
     "duration": 0.47829,
     "end_time": "2023-12-10T23:48:11.799133",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.320843",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "pred_cv_lasso_test <- predict(\n",
    "    fit_cv_lasso, \n",
    "    newx = all_x[train_ids == FALSE,],\n",
    "    s = fit_cv_lasso$lambda.min, \n",
    "    type='response'\n",
    ")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "03463765",
   "metadata": {
    "papermill": {
     "duration": 0.02764,
     "end_time": "2023-12-10T23:48:11.853564",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.825924",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.2 Submission Format"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 30,
   "id": "2c6393b3",
   "metadata": {
    "_uuid": "df586ac1a39965a4426b6a51d4e3c35de25d2255",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:11.912787Z",
     "iopub.status.busy": "2023-12-10T23:48:11.911003Z",
     "iopub.status.idle": "2023-12-10T23:48:11.971871Z",
     "shell.execute_reply": "2023-12-10T23:48:11.969443Z"
    },
    "papermill": {
     "duration": 0.094186,
     "end_time": "2023-12-10T23:48:11.975339",
     "exception": false,
     "start_time": "2023-12-10T23:48:11.881153",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<table class=\"dataframe\">\n",
       "<caption>A data.frame: 6 × 2</caption>\n",
       "<thead>\n",
       "\t<tr><th></th><th scope=col>Id</th><th scope=col>Prediction</th></tr>\n",
       "\t<tr><th></th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>\n",
       "</thead>\n",
       "<tbody>\n",
       "\t<tr><th scope=row>1</th><td> 3</td><td>0.9945455</td></tr>\n",
       "\t<tr><th scope=row>2</th><td> 5</td><td>0.9854381</td></tr>\n",
       "\t<tr><th scope=row>3</th><td> 8</td><td>0.9702071</td></tr>\n",
       "\t<tr><th scope=row>4</th><td>14</td><td>0.7618807</td></tr>\n",
       "\t<tr><th scope=row>5</th><td>20</td><td>0.8975203</td></tr>\n",
       "\t<tr><th scope=row>6</th><td>22</td><td>0.2249501</td></tr>\n",
       "</tbody>\n",
       "</table>\n"
      ],
      "text/latex": [
       "A data.frame: 6 × 2\n",
       "\\begin{tabular}{r|ll}\n",
       "  & Id & Prediction\\\\\n",
       "  & <dbl> & <dbl>\\\\\n",
       "\\hline\n",
       "\t1 &  3 & 0.9945455\\\\\n",
       "\t2 &  5 & 0.9854381\\\\\n",
       "\t3 &  8 & 0.9702071\\\\\n",
       "\t4 & 14 & 0.7618807\\\\\n",
       "\t5 & 20 & 0.8975203\\\\\n",
       "\t6 & 22 & 0.2249501\\\\\n",
       "\\end{tabular}\n"
      ],
      "text/markdown": [
       "\n",
       "A data.frame: 6 × 2\n",
       "\n",
       "| <!--/--> | Id &lt;dbl&gt; | Prediction &lt;dbl&gt; |\n",
       "|---|---|---|\n",
       "| 1 |  3 | 0.9945455 |\n",
       "| 2 |  5 | 0.9854381 |\n",
       "| 3 |  8 | 0.9702071 |\n",
       "| 4 | 14 | 0.7618807 |\n",
       "| 5 | 20 | 0.8975203 |\n",
       "| 6 | 22 | 0.2249501 |\n",
       "\n"
      ],
      "text/plain": [
       "  Id Prediction\n",
       "1  3 0.9945455 \n",
       "2  5 0.9854381 \n",
       "3  8 0.9702071 \n",
       "4 14 0.7618807 \n",
       "5 20 0.8975203 \n",
       "6 22 0.2249501 "
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
       "<ol class=list-inline><li>30000</li><li>2</li></ol>\n"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item 30000\n",
       "\\item 2\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. 30000\n",
       "2. 2\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] 30000     2"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# transforming the cv lasso predictions into the right format\n",
    "cv_lasso_submission <- \n",
    "    pred_cv_lasso_test %>% \n",
    "    as.data.frame() %>%\n",
    "    rownames_to_column(\"Id\") %>%\n",
    "    rename(Prediction = s1) %>%\n",
    "    mutate(Id = as.numeric(Id)) %>%\n",
    "    arrange(Id)\n",
    "\n",
    "head(cv_lasso_submission)\n",
    "dim(cv_lasso_submission)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 31,
   "id": "4ed24e2e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:48:12.037346Z",
     "iopub.status.busy": "2023-12-10T23:48:12.035425Z",
     "iopub.status.idle": "2023-12-10T23:48:12.077557Z",
     "shell.execute_reply": "2023-12-10T23:48:12.075269Z"
    },
    "papermill": {
     "duration": 0.07627,
     "end_time": "2023-12-10T23:48:12.080378",
     "exception": false,
     "start_time": "2023-12-10T23:48:12.004108",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Write your predictions data frame to file\n",
    "write_csv(cv_lasso_submission, file = \"submission.csv\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "acd9615d",
   "metadata": {
    "papermill": {
     "duration": 0.028303,
     "end_time": "2023-12-10T23:48:12.136834",
     "exception": false,
     "start_time": "2023-12-10T23:48:12.108531",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.3 Conclusion\n",
    "In conclusion, our analysis of the dataset containing written reviews and their ratings of various baby products led us to select the Lasso regression model for automatic feature selection. The Lasso model has proven to be highly effective, as evidenced by Area Under the Curve (AUC) score for the test data of `0.95497`. This achievement signifies the model's capability to distinguish between \"satisfied\" and \"dissatisfied\" reviews based on text features.\n",
    "\n",
    "However, it's important to note that our findings come with certain considerations:\n",
    "\n",
    "1. Our ability to generalize these results is confined to a specific population - English-speaking parents who review baby products. Given that the dataset predominantly comprises reviews from this demographic, the model's applicability to other populations may be limited.\n",
    "\n",
    "2. While our Lasso model remarkably well, it's essential to recognize that human reviewers possess innate abilities to comprehensively analyze text, considering the overall meaning of sentences and integrating various text segments to draw coherent conclusions. The Bayes' error bound, representing the theoretical limit of human performance, was estimated to be around 90%, but might be even higher in reality.\n",
    "\n",
    "3. We opted for the Lasso regression model due to its ability to handle high-dimensional feature spaces and feature selection. The choice proved to be judicious, given the high AUC score. The Lasso model excels when a subset of features strongly influences the response variable (Rating), and in our dataset, specific words, combinations, or structural features significantly affect the ratings.\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "2ca44193",
   "metadata": {
    "papermill": {
     "duration": 0.02872,
     "end_time": "2023-12-10T23:48:12.193488",
     "exception": false,
     "start_time": "2023-12-10T23:48:12.164768",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = div_labor_refs style = 'font-size:26px; background: #FF9900; padding: 10px; border-radius: 10px;'>\n",
    "7. Division of Labor & References\n",
    "</h1>\n",
    "\n",
    "## 7.1 Division of Labor\n",
    "Authors: Y, M, L    \n",
    "\n",
    "All authors contributed equally to all phases of creating the notebook but with certain focus points:\n",
    "* Y: Model fitting, model comparisons, \n",
    "* M: Introduction, structural features, notebook writing, interpretation of model evaluation\n",
    "* L: TF_IDF features, model fitting, model comparisons,\n",
    "\n",
    "## 7.2 References\n",
    "\n",
    "- Eslami, S. P., Deal, K. & Hassanein, K. (2018, June 4). \"Reviews’ length and sentiment as correlates of online reviews’ ratings.\" Internet Research, 28(3), 544–563. https://doi.org/10.1108/intr-12-2016-0394"
   ]
  }
 ],
 "metadata": {
  "kaggle": {
   "accelerator": "none",
   "dataSources": [
    {
     "databundleVersionId": 6530098,
     "sourceId": 60510,
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
   "duration": 1895.817716,
   "end_time": "2023-12-10T23:48:13.452198",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2023-12-10T23:16:37.634482",
   "version": "2.4.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
