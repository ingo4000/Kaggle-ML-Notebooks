{
 "cells": [
  {
   "cell_type": "markdown",
   "id": "2f85bf49",
   "metadata": {
    "papermill": {
     "duration": 0.020172,
     "end_time": "2023-12-10T23:29:01.159297",
     "exception": false,
     "start_time": "2023-12-10T23:29:01.139125",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<div style=\"font-size:24px; \n",
    "            text-align:center;\n",
    "            border-radius: 0px 0px 50px 50px;\n",
    "            background: #202680;\n",
    "            color: #fffff7;\n",
    "            padding: 10px;\">\n",
    "    <b>\n",
    "        Facial Expression Recognition - BDA Competition 2023\n",
    "    </b>\n",
    "    <br>        \n",
    "    <span style='font-size:18px;'>\n",
    "        Round 2, Group 5\n",
    "    </span>\n",
    "</div><br>\n",
    "\n",
    "<h1 id = intro style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    1. Introduction & Data Considerations\n",
    " </h1>\n",
    "In this competition our task is to build an algorithm that is able to recognize emotions from photographs depicting facial expressions. The data set contains photos of faces that express one of the following emotions:   \n",
    "\n",
    "* Anger\n",
    "* Disgust\n",
    "* Happiness\n",
    "* Sadness \n",
    "\n",
    "\n",
    "## 1.1 Table of Contents\n",
    "\n",
    "* [Introduction & Data Considerations](intro)\n",
    "* [Data Import](import)\n",
    "* [Feature Extraction](features)\n",
    "* [Model Fitting](modelfit)\n",
    "* [Model Evaluation](modeleval)\n",
    "* [Prediction on Test Data, Submisson & Conclusion](submission)\n",
    "* [Division of Labor & References](div_labor_refs)\n",
    "\n",
    "\n",
    "\n",
    "## 1.2 Data considerations\n",
    "\n",
    "**1. Where do the data come from? (To which population will results generalize?)**\n",
    "\n",
    ">The data comes from the extended `Cohn Kanade` dataset (`CK+`; Lucey et al., 2010) and includes 593 still photographs from a video with 123 actors between 18 and 50 years old. These actors were asked to express on an emotion that was subsequently labelled as one of the following emotions: anger, contempt, disgust, fear, happiness, sadness, and surprise. In this notebook we will predict only the following four emotions: disgust, anger, happiness, and sadness. The results of the predicitions will generalize to black and white photos of mainly adult faces with these four emotions. However, it should be noted that the training data consists of photos of actors' expressions of certain emotions. It is not clear if our results can be generalized to more naturally occurring facial expressions of these emotions.\n",
    "\n",
    "**2. What are candidate machine learning methods? (models? features?)**\n",
    "\n",
    "> Considering the present task, possible types of features to extract from the images include\n",
    "> * Raw pixel features\n",
    "> * Statistical / Histogram-based features\n",
    "> * Bag-of-Features models\n",
    "\n",
    "> For the present classification problem, candidate classifiers include \n",
    "> * Multinomial Logistic Regression\n",
    "> * Linear Discriminant Analysis\n",
    "> * Quadratic Discriminant Analysis\n",
    "> * Tree Based Classification Methods\n",
    "    * Boosting\n",
    "    * Bagging\n",
    "    * Random Forests\n",
    "> * Support Vector Machines\n",
    "\n",
    "\n",
    "**3. What is the Bayes' error bound? (Any guestimate from scientific literature or web resources?)**\n",
    "\n",
    "> To have an idea of a lower bound on the Bayes bound (i.e., the minimum accuracy that should be achievable). The best 'machine' we have at hand to recognize emotion from facial expression in the human brain. How often do human judges get it correct? In a study by Mollahosseini et al. (2018) an estimate for human classification inter-rater agreement was obtained for 11 emotions. For the four included in this data set they are:\n",
    "><table>\n",
    "    <thead>\n",
    "    <tr><td>disgust</td><td>anger</td><td>happy</td><td>sad</td></tr>\n",
    "    </thead>\n",
    "    <tbody>\n",
    "        <tr><td>67.6%</td><td>62.3%</td><td>79.6%</td><td>69.7%</td></tr>\n",
    "    </tbody>\n",
    "</table>\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "6582da1b",
   "metadata": {
    "papermill": {
     "duration": 0.017943,
     "end_time": "2023-12-10T23:29:01.195319",
     "exception": false,
     "start_time": "2023-12-10T23:29:01.177376",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    " <h1 id = import style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    2. Data Import\n",
    " </h1>\n",
    " \n",
    "In this section, we first get the notebook started by loading the respective packages, reading in and checking the data. It's important to take a look at the images in the CK+ dataset before extracting features.\n",
    " \n",
    " ## 2.1 Setup & Loading the Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "id": "fed2ce8f",
   "metadata": {
    "_execution_state": "idle",
    "_uuid": "051d70d956493feee0c6d64651c6a088724dca2a",
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:01.237696Z",
     "iopub.status.busy": "2023-12-10T23:29:01.234540Z",
     "iopub.status.idle": "2023-12-10T23:29:06.110602Z",
     "shell.execute_reply": "2023-12-10T23:29:06.108146Z"
    },
    "papermill": {
     "duration": 4.900716,
     "end_time": "2023-12-10T23:29:06.113993",
     "exception": false,
     "start_time": "2023-12-10T23:29:01.213277",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "## Importing packages ------------------------ \n",
    "suppressPackageStartupMessages(library(tidyverse))\n",
    "suppressPackageStartupMessages(library(e1071)) \n",
    "suppressPackageStartupMessages(library(png)) \n",
    "suppressPackageStartupMessages(library(caret))\n",
    "suppressPackageStartupMessages(library(doParallel))\n",
    "\n",
    "## Reading in files --------------------------\n",
    "# Show the availabe directories\n",
    "dirs <- dir(\"../input\", pattern=\"[^g]$\", recursive=TRUE, include.dirs = TRUE, full.names = TRUE)\n",
    "\n",
    "# Get all image files: file names ending \".png\" \n",
    "anger   <- dir(grep(\"anger\",   dirs, value = TRUE), pattern = \"png$\", full.names = TRUE)\n",
    "disgust <- dir(grep(\"disgust\", dirs, value = TRUE), pattern = \"png$\", full.names = TRUE)\n",
    "happy   <- dir(grep(\"happy\",   dirs, value = TRUE), pattern = \"png$\", full.names = TRUE)\n",
    "sad     <- dir(grep(\"sad\",     dirs, value = TRUE), pattern = \"png$\", full.names = TRUE)\n",
    "test_im <- dir(grep(\"test\",    dirs, value = TRUE), pattern = \"png$\", full.names = TRUE)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "8309eda6",
   "metadata": {
    "papermill": {
     "duration": 0.018495,
     "end_time": "2023-12-10T23:29:06.150649",
     "exception": false,
     "start_time": "2023-12-10T23:29:06.132154",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 2.1.1 Inspecting the data\n",
    "Let's take a look at the different facial emotion expressions**"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "id": "40570b13",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:06.253582Z",
     "iopub.status.busy": "2023-12-10T23:29:06.193125Z",
     "iopub.status.idle": "2023-12-10T23:29:06.308443Z",
     "shell.execute_reply": "2023-12-10T23:29:06.304883Z"
    },
    "papermill": {
     "duration": 0.147127,
     "end_time": "2023-12-10T23:29:06.315472",
     "exception": false,
     "start_time": "2023-12-10T23:29:06.168345",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "<img src=\"happy.png\" width=\"200\" style=\"float:left\" /><img src=\"sad.png\" width=\"200\" style=\"float:left\" /><img src=\"anger.png\" width=\"200\" style=\"float:left\" /><img src=\"disgust.png\" width=\"200\" style=\"float:left\" />"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "ok <- file.copy(  happy[60], \"happy.png\", overwrite = TRUE)\n",
    "ok <- file.copy(    sad[61],   \"sad.png\", overwrite = TRUE)\n",
    "ok <- file.copy(  anger[61], \"anger.png\", overwrite = TRUE)\n",
    "ok <- file.copy(disgust[61], \"disgust.png\", overwrite = TRUE)\n",
    "IRdisplay::display_html('<img src=\"happy.png\" width=\"200\" style=\"float:left\" /><img src=\"sad.png\" width=\"200\" style=\"float:left\" /><img src=\"anger.png\" width=\"200\" style=\"float:left\" /><img src=\"disgust.png\" width=\"200\" style=\"float:left\" />')"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "04b9f69f",
   "metadata": {
    "papermill": {
     "duration": 0.01834,
     "end_time": "2023-12-10T23:29:06.356305",
     "exception": false,
     "start_time": "2023-12-10T23:29:06.337965",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 2.2 Data Import\n",
    "\n",
    "When working with image data, you often have many more Gigabytes of raw data than you have RAM memory available. Therefore, it is often not possible to work with all data \"in memory\". Resizing images often helps, but may cause loss of information.\n",
    "\n",
    "The images for this competition are\n",
    "\n",
    "- gray scale, so we need only one *color channel* \n",
    "- are only 48 by 48 pixels\n",
    "\n",
    "Furthermore there are only 2538 pictures in the training set. Therefore, we are lucky enough to be able to retain all images in RAM, and don't have to do \"special stuff\" to handle reading in image files while fitting a model.\n",
    "\n",
    "Reading in images pixelwise is easiest: We simply store each image as a long vector of pixel intensities, row by row. Also we will need a vector that contains the emotion label for each of the images."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "id": "a0d7e2c0",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:06.396843Z",
     "iopub.status.busy": "2023-12-10T23:29:06.394996Z",
     "iopub.status.idle": "2023-12-10T23:29:19.739731Z",
     "shell.execute_reply": "2023-12-10T23:29:19.736988Z"
    },
    "papermill": {
     "duration": 13.369084,
     "end_time": "2023-12-10T23:29:19.743871",
     "exception": false,
     "start_time": "2023-12-10T23:29:06.374787",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "                                    p20        p21        p22        p23\n",
      "anger/S010_004_00000018a.png 0.58039216 0.60784314 0.70196078 0.85882353\n",
      "anger/S010_004_00000018b.png 0.02745098 0.02745098 0.04313725 0.07450980\n",
      "anger/S010_004_00000018c.png 0.03529412 0.03137255 0.02745098 0.01960784\n",
      "anger/S010_004_00000018d.png 0.03921569 0.03137255 0.03137255 0.02745098\n"
     ]
    },
    {
     "data": {
      "text/plain": [
       "y\n",
       "  anger disgust   happy     sad \n",
       "    570     744     870     354 "
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "                             p20       p21       p22       p23\n",
      "S010_004_00000017a.png 0.7764706 0.8196078 0.8980392 0.9803922\n",
      "S010_004_00000017b.png 0.4666667 0.5254902 0.6352941 0.7490196\n",
      "S010_004_00000017c.png 0.2549020 0.3450980 0.4980392 0.6745098\n"
     ]
    }
   ],
   "source": [
    "# Combine all filenames into a single vector\n",
    "train_image_files <- c(anger, happy, sad, disgust)\n",
    "\n",
    "# Read in the images as pixel values (discarding color channels)\n",
    "X <- sapply(train_image_files, function(nm) c(readPNG(nm)[, , 1])) %>% t()\n",
    "y <- c(\n",
    "  rep(\"anger\", length(anger)),\n",
    "  rep(\"happy\", length(happy)),\n",
    "  rep(\"sad\", length(sad)),\n",
    "  rep(\"disgust\", length(disgust))\n",
    ")\n",
    "\n",
    "X_test <- sapply(test_im, function(nm) c(readPNG(nm)[, , 1])) %>% t()\n",
    "\n",
    "\n",
    "# Change row and column names of X to something more managable (caret::train requires column names)\n",
    "rownames(X) <- gsub(\".+train/\", \"\", rownames(X))\n",
    "rownames(X_test) <- gsub(\".+test/\", \"\", rownames(X_test))\n",
    "\n",
    "colnames(X) <- colnames(X_test) <- paste(\"p\", 1:ncol(X), sep = \"\")\n",
    "\n",
    "# Check result (are X, X_test, and y what we expect)\n",
    "X[1:4, 20:23] %>% print()\n",
    "table(y)\n",
    "# Call X X_train (handy for later)\n",
    "X_train <- X\n",
    "\n",
    "X_test[1:3, 20:23] %>% print()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 4,
   "id": "76b3da52",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:19.788510Z",
     "iopub.status.busy": "2023-12-10T23:29:19.786391Z",
     "iopub.status.idle": "2023-12-10T23:29:19.806304Z",
     "shell.execute_reply": "2023-12-10T23:29:19.803983Z"
    },
    "papermill": {
     "duration": 0.045594,
     "end_time": "2023-12-10T23:29:19.809875",
     "exception": false,
     "start_time": "2023-12-10T23:29:19.764281",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# A function to visualize the data as an image\n",
    "as_image <- function(x, nr = sqrt(length(x))) {\n",
    "  opar <- par(mar = rep(0, 4))\n",
    "  on.exit(par(opar))\n",
    "  image(t(matrix(x, nr))[, nr:1],\n",
    "    col = gray(0:255 / 255), axes = FALSE\n",
    "  )\n",
    "}"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "dbfb1435",
   "metadata": {
    "papermill": {
     "duration": 0.019391,
     "end_time": "2023-12-10T23:29:19.847760",
     "exception": false,
     "start_time": "2023-12-10T23:29:19.828369",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    " <h1 id = features style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    3. Feature Extraction\n",
    " </h1>\n",
    " \n",
    "In the following sections we extract features using these approaches:\n",
    "* Raw Pixel Approach\n",
    "* Edge-Based Histogram Features (including Frey & Slate Features)\n",
    "* Histogram of Oriented Gradient Features\n",
    "* Power Spectral Density (PSD) Features\n",
    "\n",
    "Each section is structured in a way that we first define so called \"helper functions\" that compute the repective features and then, secondly, these helper functions are applied to all the images in the data set."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "70762196",
   "metadata": {
    "papermill": {
     "duration": 0.018507,
     "end_time": "2023-12-10T23:29:19.885503",
     "exception": false,
     "start_time": "2023-12-10T23:29:19.866996",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### Combining test and train data\n",
    "Having prepared the data we first combine test and train data in order to compute features simultaneously. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "id": "9ae1c253",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:19.927891Z",
     "iopub.status.busy": "2023-12-10T23:29:19.925837Z",
     "iopub.status.idle": "2023-12-10T23:29:20.600230Z",
     "shell.execute_reply": "2023-12-10T23:29:20.597647Z"
    },
    "papermill": {
     "duration": 0.699863,
     "end_time": "2023-12-10T23:29:20.603956",
     "exception": false,
     "start_time": "2023-12-10T23:29:19.904093",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# merge X_train and X_test for the moment to compute features\n",
    "X <- rbind(X_train, X_test)\n",
    "\n",
    "# save index of training data\n",
    "train_index <- 1:nrow(X_train)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "07569a82",
   "metadata": {
    "papermill": {
     "duration": 0.018319,
     "end_time": "2023-12-10T23:29:20.640580",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.622261",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.1 Raw Pixel Approach\n",
    "In this section, we initiate the feature extraction by using the raw pixel approach. We compute essential statistics each for both the rows and the columns of the raw pixel data:\n",
    "\n",
    "* mean\n",
    "* median\n",
    "* sd\n",
    "* skew\n",
    "* kurtosis\n",
    "\n",
    "In a previous version of our notebook, we included the actual raw pixel data as predictors but the model evaluation has indicated that our predictions are more accurate when omitting the raw pixel data and keeping these summary statistics on the raw pixel data.\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c094ac6f",
   "metadata": {
    "papermill": {
     "duration": 0.018334,
     "end_time": "2023-12-10T23:29:20.677218",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.658884",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.1.1 Raw Pixel Helper functions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 6,
   "id": "20f3e9b2",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:20.718753Z",
     "iopub.status.busy": "2023-12-10T23:29:20.716663Z",
     "iopub.status.idle": "2023-12-10T23:29:20.738262Z",
     "shell.execute_reply": "2023-12-10T23:29:20.736181Z"
    },
    "papermill": {
     "duration": 0.045379,
     "end_time": "2023-12-10T23:29:20.741008",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.695629",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Calculate raw-pixel features\n",
    "# row/col means helper function (function to calculate row and column means for an image)\n",
    "calculate_image_means <- function(row, dim_image = sqrt(length(row))) {\n",
    "  # Convert the row to a matrix\n",
    "  image <- matrix(as.numeric(row), nrow = dim_image, byrow = TRUE)\n",
    "  # Calculate row and column means\n",
    "  row_means <- rowMeans(image)\n",
    "  col_means <- colMeans(image)\n",
    "  # put in dataframe\n",
    "  result <-\n",
    "    data.frame(c(row_means, col_means),\n",
    "      row.names = c(\n",
    "        paste(\"row\", 1:dim_image, \"mean\", sep = \"_\"),\n",
    "        paste(\"col\", 1:dim_image, \"mean\", sep = \"_\")\n",
    "      )\n",
    "    )\n",
    "  # transform because now it's a column and all the row/col means should be\n",
    "  # the rows in the final dataframe\n",
    "  result <- result %>%\n",
    "    t() %>%\n",
    "    data.frame(row.names = rownames(row))\n",
    "  return(result)\n",
    "}\n",
    "\n",
    "# helper function to calculate stats on the row & col sums of the raw pixal images\n",
    "calculate_image_sum_stats <- function(image_as_row, dim_image = sqrt(length(row))) {\n",
    "  image_sum_stats <- image_as_row %>%\n",
    "    unlist() %>%\n",
    "    matrix(nrow = dim_image, ncol = dim_image) %>%\n",
    "    as_tibble() %>%\n",
    "    summarise(\n",
    "      col_skew = e1071::skewness(colSums(.)),\n",
    "      row_skew = e1071::skewness(rowSums(.)),\n",
    "      col_kurt = e1071::kurtosis(colSums(.)),\n",
    "      row_kurt = e1071::kurtosis(rowSums(.)),\n",
    "      col_med = median(colSums(.), na.rm = TRUE),\n",
    "      row_med = median(rowSums(.), na.rm = TRUE),\n",
    "      col_sd = sd(colSums(.)),\n",
    "      row_sd = sd(rowSums(.))\n",
    "    ) %>%\n",
    "    unlist()\n",
    "  image_sum_stats\n",
    "}"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "31ff038d",
   "metadata": {
    "papermill": {
     "duration": 0.018337,
     "end_time": "2023-12-10T23:29:20.778247",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.759910",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.1.2 Extracting raw pixel features\n",
    "Applying the functions as to extract the features from the raw pixel images. "
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "id": "8e7bfbd8",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:29:20.819168Z",
     "iopub.status.busy": "2023-12-10T23:29:20.817245Z",
     "iopub.status.idle": "2023-12-10T23:30:30.624173Z",
     "shell.execute_reply": "2023-12-10T23:30:30.620744Z"
    },
    "papermill": {
     "duration": 69.850609,
     "end_time": "2023-12-10T23:30:30.647152",
     "exception": false,
     "start_time": "2023-12-10T23:29:20.796543",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "'96 features based on the raw-pixel row/column mean'"
      ],
      "text/latex": [
       "'96 features based on the raw-pixel row/column mean'"
      ],
      "text/markdown": [
       "'96 features based on the raw-pixel row/column mean'"
      ],
      "text/plain": [
       "[1] \"96 features based on the raw-pixel row/column mean\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stderr",
     "output_type": "stream",
     "text": [
      "Warning message:\n",
      "“\u001b[1m\u001b[22mThe `x` argument of `as_tibble.matrix()` must have unique column names if\n",
      "`.name_repair` is omitted as of tibble 2.0.0.\n",
      "\u001b[36mℹ\u001b[39m Using compatibility `.name_repair`.”\n"
     ]
    },
    {
     "data": {
      "text/html": [
       "'8 features based on the raw-pixel sum stats'"
      ],
      "text/latex": [
       "'8 features based on the raw-pixel sum stats'"
      ],
      "text/markdown": [
       "'8 features based on the raw-pixel sum stats'"
      ],
      "text/plain": [
       "[1] \"8 features based on the raw-pixel sum stats\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Apply the rol/col-mean function to each row\n",
    "features_col_row_means <- X %>%\n",
    "  split(1:nrow(.)) %>%\n",
    "  map_dfr(calculate_image_means) %>%\n",
    "  ungroup()\n",
    "paste(ncol(features_col_row_means), \"features based on the raw-pixel row/column mean\")\n",
    "\n",
    "# Apply the image-sum-stats function to each row\n",
    "features_image_sum_stats <- X %>%\n",
    "  split(1:nrow(.)) %>%\n",
    "  map_dfr(calculate_image_sum_stats)\n",
    "paste(ncol(features_image_sum_stats), \"features based on the raw-pixel sum stats\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "748c0936",
   "metadata": {
    "papermill": {
     "duration": 0.019225,
     "end_time": "2023-12-10T23:30:30.685367",
     "exception": false,
     "start_time": "2023-12-10T23:30:30.666142",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.2 Edge-based Histogram Features\n",
    "\n",
    "In this section, we shift our focus from raw pixel values to the edges within the image. An edge signifies a rapid transition in pixel intensities. By computing the disparity between adjacent pixels and evaluating if it surpasses a specified threshold, we can pinpoint the pixels situated at the edges of abrupt intensity alterations. Although this process can theoretically be applied in various directions, we streamline our approach by concentrating on two pivotal directions: vertical and horizontal edges. Additionally, we incorporate diagonal edges by consecutively calculating differences in these two directions.\n",
    "\n",
    "In the context of image processing, edge-based features often correspond to important details in the image. Extracting these features thus allows us to focus on key aspects of the image, which can be valuable for the subsequent classification task.\n",
    "\n",
    "The following helper functions facilitate the calculation of edge-based features:\n",
    "* `calc_edge_values`: Takes a vector of pixel values (x_pixels) & converts it into 48x48 matrix. Then computes four types of edge values (horizontal, vertical, diagonal 1, and diagonal 2).\n",
    "* `make_edges`: Takes list of edge values (x_edges) & convert them into binary edges, marking regions with significant intensity changes.\n",
    "* `calc_frey_slate_feat`: Calculates Frey and Slate features for a given set of edge values. These features capture statistical characteristics of the edges (e.g., number of \"on\" pixels, mean horizontal/vertical position of the pixels, mean squared value of the vertical/horizontal pixel distances, etc. See [this article](http://link.springer.com/content/pdf/10.1007/BF00114162.pdf) written about these features.\n",
    "* `entropy`: This function computes the entropy of a given vector x, which is a measure of the disorder/randomness in the intensity values.\n",
    "* `calc_hist_feat`: Given a list of binary edge images, this function extracts various statistical features for each edge type. These features include mean, standard deviation, skewness, kurtosis, and entropy.\n",
    "\n",
    "With these functions, we proceed to compute edge features for our dataset. The following steps are performed:\n",
    "1. **Computing Edge Values**\n",
    "2. **Converting to Binary Edges**\n",
    "3. **Computing Frey & Slate Features** (for each type of edge: horizontal, vertical, diagonal 1, and diagonal 2)\n",
    "4. **Computing Edge-Based Histogram Features**"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b08cc6b8",
   "metadata": {
    "papermill": {
     "duration": 0.019238,
     "end_time": "2023-12-10T23:30:30.723373",
     "exception": false,
     "start_time": "2023-12-10T23:30:30.704135",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.2.1 Edge features Helper functions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 8,
   "id": "fc68b67b",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:30.767262Z",
     "iopub.status.busy": "2023-12-10T23:30:30.765312Z",
     "iopub.status.idle": "2023-12-10T23:30:31.535784Z",
     "shell.execute_reply": "2023-12-10T23:30:31.533411Z"
    },
    "papermill": {
     "duration": 0.797396,
     "end_time": "2023-12-10T23:30:31.540130",
     "exception": false,
     "start_time": "2023-12-10T23:30:30.742734",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Load FreySlateFeatures function\n",
    "source(\"https://bit.ly/32um24j\")\n",
    "\n",
    "# Computes the egde values for all pictures for use in frey slate features calculation\n",
    "calc_edge_values <- function(x_pixels) {\n",
    "  x <- matrix(x_pixels, 48)\n",
    "  edges <- list()\n",
    "  edges[[\"edge_h\"]] <- (x[-1, ] - x[-nrow(x), ]) # horizontal\n",
    "  edges[[\"edge_v\"]] <- (x[, -1] - x[, -ncol(x)]) # vertical\n",
    "  edges[[\"edge_d1\"]] <- (edges[[\"edge_h\"]][, -1] - edges[[\"edge_h\"]][, -ncol(edges[[\"edge_h\"]])]) # h - v\n",
    "  edges[[\"edge_d2\"]] <- (edges[[\"edge_v\"]][-1, ] - edges[[\"edge_v\"]][-ncol(edges[[\"edge_v\"]]), ])\n",
    "  return(edges)\n",
    "}\n",
    "\n",
    "# Makes the egdes into TRUE or FALSE using threshold\n",
    "make_edges <- function(x_edges, threshold = .1) {\n",
    "  edges <- list()\n",
    "  edges[[\"edge_h\"]] <- x_edges[[\"edge_h\"]] < threshold\n",
    "  edges[[\"edge_v\"]] <- x_edges[[\"edge_v\"]] < threshold\n",
    "  edges[[\"edge_d1\"]] <- x_edges[[\"edge_d1\"]] < threshold / 1.5\n",
    "  edges[[\"edge_d2\"]] <- x_edges[[\"edge_d2\"]] < threshold / 1.5\n",
    "  return(edges)\n",
    "}\n",
    "\n",
    "# Compute frey slate features for one picture\n",
    "calc_frey_slate_feat <- function(x_edges) {\n",
    "  fsf <- list()\n",
    "  fsf[[\"hor\"]] <- FreySlateFeatures(x_edges[[\"edge_h\"]])\n",
    "  fsf[[\"ver\"]] <- FreySlateFeatures(x_edges[[\"edge_v\"]])\n",
    "  fsf[[\"dia1\"]] <- FreySlateFeatures(x_edges[[\"edge_d1\"]])\n",
    "  fsf[[\"dia2\"]] <- FreySlateFeatures(x_edges[[\"edge_d2\"]])\n",
    "  return(unlist(fsf))\n",
    "}\n",
    "\n",
    "# Calculates Entropy (borrowed this function from the Phone Signal Competition)\n",
    "entropy <- function(x, nbreaks = nclass.Sturges(x)) {\n",
    "  r <- range(x)\n",
    "  x_binned <- findInterval(x, seq(r[1], r[2], len = nbreaks))\n",
    "  h <- tabulate(x_binned, nbins = nbreaks) # fast histogram\n",
    "  p <- h / sum(h)\n",
    "  -sum(p[p > 0] * log(p[p > 0]))\n",
    "}\n",
    "\n",
    "# Computes edge and histogram features for one image\n",
    "calc_hist_feat <- function(x_edges) {\n",
    "  output <- list()\n",
    "  # Compute features; iterate through the edge types\n",
    "  for (i in c(\"_h\", \"_v\", \"_d1\", \"_d2\")) {\n",
    "    # Mean\n",
    "    output[[paste0(\"m\", i)]] <- mean(x_edges[[paste0(\"edge\", i)]])\n",
    "    # SD\n",
    "    output[[paste0(\"sd\", i)]] <- sd(x_edges[[paste0(\"edge\", i)]])\n",
    "    # Skew\n",
    "    output[[paste0(\"ske\", i)]] <- e1071::skewness(x_edges[[paste0(\"edge\", i)]])\n",
    "    # Kurtosis\n",
    "    output[[paste0(\"kur\", i)]] <- e1071::kurtosis(x_edges[[paste0(\"edge\", i)]])\n",
    "    # entropy\n",
    "    output[[paste0(\"entropy\", i)]] <- entropy(x_edges[[paste0(\"edge\", i)]])\n",
    "  }\n",
    "  return(unlist(output))\n",
    "}"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fb3f9dff",
   "metadata": {
    "papermill": {
     "duration": 0.019501,
     "end_time": "2023-12-10T23:30:31.579725",
     "exception": false,
     "start_time": "2023-12-10T23:30:31.560224",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.2.2 Testing Edge Functions\n",
    "\n",
    "To look if our edge detection functions are actually working correctly we took one image and calculated the edges using the example and using our own functions."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 9,
   "id": "38dd8619",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:31.624097Z",
     "iopub.status.busy": "2023-12-10T23:30:31.622053Z",
     "iopub.status.idle": "2023-12-10T23:30:32.004121Z",
     "shell.execute_reply": "2023-12-10T23:30:31.997723Z"
    },
    "papermill": {
     "duration": 0.407851,
     "end_time": "2023-12-10T23:30:32.007697",
     "exception": false,
     "start_time": "2023-12-10T23:30:31.599846",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "image/png": "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\n5nL72Eg7bqS1nVf83xc//dhDV1XKA+uOOf3Fb/rI5vpvuxLvk/t6tP88aVUul9vZvEOPnjM2\n2Df6iHYHDDrwobsvX3bUOSml7z7/2Fwu98FbJlK3m+rUrRf96dMftnbFUGVg2Qn3f8x7Pvuj\nPX9+9b+cmcvlnvy1X9/+h3fd8M5cLnfU076610PN8Rr3dZqYLwocADD/ZlsTLz/z+Ge/4e+u\nSoc+7vef84ATxr77mfc99tTjzvnOrXt+YMdVHzvh1Med+4ULqoed+pQnnllc/52X/O4Jb//x\n5tuO0Ji84tHH3+9dn/zqqhMf/AdPPrN+xRceddxpX9w2vU9n2auJW8+959P+/Jc7Rx/55Gc9\n7LS73XDRl1/+hFNeeO5e/iu9f+yJ3/jrh+26/uOPf++P9/zJhm+99k+/ctM9Xvpff3bqin09\n+yXvePRDnvvG71yffvcpf/i8pz++ePOl73zZ4x/1zh93N4Zx31JKU5u/dMrxj3zveV8fvsdD\nnv1HL3zCw+9xww++9KqnnXr2RRtvf5bH3OtpF04d/ZJXv+45jz/pusvOf8nD7/P6Z9zjBe++\n8F6Pe84fP+dxkzdd/reveOTZP9nSxeh1PUFAmtvtYyPtuJHWdl/y8Lvf+y3nfr5yxL3+8LlP\nO3bg5o+8/cUnPfBPZ2ZTmvM+OcejdSHuwBlvfe/73vaIlNIxz/u/H/7wh88cqXQ3WY2pKx92\nwkP/6Vs33eOMJzzstKN+fen5r3vGfZ767ktSSkc85R2FXO4Hb7hDLeOyN/9TSum577p/l1e1\n79PEPMo94AEPaJddfPHFQcv4QfRDDz00SE855ZQgHRsbC9JqtRqkQ0NDQTowMBCkwWc9Op43\nTuPPmKSU+vv7g7Svry9Iu/6ISny9vTyW3/HjD6VSqV3Uy0dUgsOmOXxEJbBYH1GJRzL+QEfc\nNk7jD3T0opePqDSb0VeRx33etWtXkF5+efQvFT//+c+DdMeOHUEaX9H27duDtEe93Eq93Czc\n5mfvevCpf/6901/1iR+c85xyLqWUNl5y3mkPed6W0j1u2X7Z8mJ69qHD520Yf9EHL/jHPzkj\npTTbmnjv8+79mk9dmVL6721Tjx2tfulZxzzxX68969xLzz3r3imlVm3DKx5wz7+/bHP/yt+b\n2PzZuZ1lL8vg9KHK/4zXVtzjBd/7wT8eP1BKKW27/N9Pu88f3twc/cmODSf3F796/0Mee/Et\n1083jqwUUkpptvZ/Thg797r8lzfc/KihTQ9afdzP+3/3pl9/YXkxP5ezf/MxRzzyazf9YNfM\n/YdKR/eVby7d86rNF+85cm33ZWtX3Hdy8GFT277R1Rjmgr6llC555Sm/8/7Lf/+8qz7zB8fu\nOeDWn56z8p6vOfSMr918we+mlC581t3P+NdrVp322qsveddIIZdS+ten3u1ZX7ih1H/89278\n8X1XVlNK15z35Ls/+7+Oe/73rvznB85l9O54yeUuJoiloOMW2ss+aX+eozncPrM20o4b6bkP\nX/eib61/+b/94v3PODGllFLz3D847kWfufZZ3/j1px+xruM+ecezl+OjpZT+86RVT7liy45G\na8+musdzxgb/o3a/qe3fvNPR0hw26p3Xv2bZUec8+OO/uvB5d+9lslbe66wffO9Dd+8vppS2\n/fzfTrvvs39dr35r69YzRsqvPnzkb28trp/YvKaU3zNZpw0PXVG478SO7+71P5Y6XmNKs/s6\nTcxdxy3UExwAMP9e/s5LK8MP/PZ7nl3+37+Ix+77h/9+1nG18R+/88ad4xs+eN6G8dWnv2/P\nL+UppVx+4FX/dMGR1d8Ul2ebO//oczcMrjlrzy/lKaV8+ZB3fOHN+3SWoHvnfPXv9vxSnlJa\nfvIzvvjW05v1za/40o17+dFc+ZxvfWxodsdzH/mWz734UT8cT++94F/2VBD26eyzrcmbZpqF\n0tietiml8tDpl1z6o+9/85zuxjDuW0rp0Ee++eMf//jfP+OY2w647Pinp5RmNt/h28de+rk3\n3fZL6kNecXxK6eTXfHpPdSOltO4xL0opTd16hyZzH72uJwjoePvYSFOnjbQxecXLLtiw7Og3\n/G89IqVUeM7fved+97tf4/tb05z3yTkerQv71IHUw2T9/Vffv6e6kVJafsozv/h/T281x8/+\n9LUppbNef1Krvu31l/3mwZ/tv3rLj8drxzz3PV1/x1IXf98xj7xFBQDmWX38su/smBlce8K/\nf/yfbv/nOwbyKaVLfrR12+B/pZROOvtJt0/zpbG33H3Z83++JaU0ufGTm+vNY858zu1/YGjd\nS5aXXnnbo9Udz5KOXrbX7pUHT3veIXd4pPGY57w4vfaHV3/suvTMo+/68wOHPPWbbzvjPn/+\n7mf+JP3O2d9+0XHLujh7Lj/wzoce8ppv/fdhxz34+X/wpDMe+ID73f++R596r732cO7H32vf\n9jj0cc94Xkqzzcnrf/mr62644Ybrrv3ul/7hrie69/Bvv+e7tKyUUlp95urb/iRfGr3Tz899\n9LqeIGAut8+2H9tIO2yk4xs+ONOaPfHZv3f7P6yueMpFFz1lz/+e4z45x6N1YZ860PVkVYYf\n8MyxOzwvf8xzX5Re98MbPnVDeskJR/3BW3Ive/T/O/vC9O2np5QuPvtfU0p/9oboAwexfZ0m\n5pcCBwDMs8bUr1JK47d89KyzPnrXdGrD1OTAZEpp2QnDd4qOPGEk/XxLSqk+dWVKaeCoO36y\nMlc8slK8cs5nade9Uv+Jd/6TgVNTSpM3t/0nuHu+/MNDbzxhvDX7+lf+Ttdn/7Ov/2z5u97y\n4X/59w+89XUfSCmXL59y5lPe8O6/e+bpq+76w3M//l379psjTF75lpe8/B/+9Vvba81cvrTm\niGPueZ8zU7rzFxCmuzzrmstHj7/OffS6niBgLrfP5HobaYeNdGb7jSml4bsM0W3muk/O7Whd\n2KcOzOtk3TOlVNu+K6VUGX3UH68Z+KeLXzfe/L2B3OSrvn5z/+rff+Ga6JsNOtqnaWJ++YgK\nAMyzQvnQlNKa+35xdm9++KqTB+82mFLaceWdvx1mYuP0/x5hbUpp4oaJO+atm2u//TKajmdp\n17365J2/Bm/Pn1RWtH2g4N9f9Pjx2UI1l178uLe1uj17rrj8BW/8wA9/deuOX//yy58595XP\nfdS13/nsHz7g5O/u2st36Mz9+Hft2x5vvP+D3v6Jbzz0lX/zvZ9eMz4zs+G6K/770+9td4Fz\nN/fR63qCgLncPjbSjhtpaXh5Smnypsl2XdqnfbLj0drZ3Wz7lXP71IEeJuuXd/mTK1JKA0es\n2PN/X/rKExrTN7z5yu3bLj/7qsn6ya95wz5dYLrLNe7TNDG/FDgAYJ6VRx50Yn9p13Ufv9Pv\ndNd88u2vetWrvr+rNnrK76WUfvHOL98hnq29+3/f1tG/+rnVfO7Wb3/m9vnELR/bdLvfyzue\npV33auP/86lb7/Ab6vX/9uGU0lHPu9tef/7W77752eddc/KffvHLf3avzT96x7M+cXUXZ5/e\n+l9nn332ez93Y0ppZN3xj/v9s977z1+68K/u1axteucvtt31pHM8/l77llJqTP7i3T/buuzo\n93zuXa984D2O7i/mUkqt+ubUs7mPXtcTBMzl9rGRdtxIB9eclcvlrvuXr92h57svKuTzq089\nb1/3yfhot//DnY3fXlBz+rpv7Nj7d67vawe6nqyZXd//jzt+qcf1n/lQSumEF/3muz+OeeHr\nU0r/9ReXfue1/5nLFd7xx8e2O9Rtgmvc12lifilwAMC8y3/ohcdNbvn8o//qi7f9BrT7+i8/\n5sVv+dA//fCeg6WBNX/8nHWDm3/0ipee+/3fxLONT7zuYd/Z+ZvfkAqVw8599GHjt3z4Tz/x\nkz1/0qpv+ounvXmfzhL071WPeeW1U795q9GmSz7xxNf9MF9cds4z9/J7eXP6mic97t3V5Y/4\nf+c86sy/Pv/RK/s+/+JHXrSrtu9nn33nO9/5Fy9709bf/lI4e8mPt6WUThnb68vCOh+/fd9S\nyhXzuVxj8urG/750olXf/Pd/+tQ91xSMzFzMefS6nyA46HW+fWyke/4k2EjLIw/5y5OXb7vi\n9W/80rW3/fx/vOqPWrOzv/Om++/rPtnhaCmllPpWV1JKb//Whv/Na//88idOtnuCY84daP3m\nerufrD957Kuvn/7NMTde/PHH//klxerhH3zMYb/p9sqnPWt1//rzX//K79wyfMRrHr4segPm\nHK5xX/++Yz4Vg7cYxi+wjF/QEr9ktJeXX8YvN50N354VnzduG19v/ILSjq+JjZvHafAG015e\nExun8ZE7vlQ1GOp4FroeijSHVwp1/dq2Xo4c32XxaMRt4xeyxuL7N35da5z28mrbWDwa8dro\nZZx7mUEObA865+tP+8ZJn3vLk9Z8+vQzH3if6vgNX/rC+btm+//qK58byOdSSh/4xvu+cer/\n+eCLHnT+R86870lj11z67Ut+ufUPX3PieX/zm8eef/+zXz3vlPt/6Pn3/tEnHn/PI/ou+/Z/\n3zD87FMGPnpdcWjuZ9mr8tC9j1n/qZOPuPDhD/2d/Jarvv2dSydas8/6wAX3HSrf9Yc//uxH\nXTreePuln15Vyqe04pNff/PYvd/4tCe8d8N3/nyfzl5d8eR3PPSQN3z7U0ccefmjzzhtbKD1\ny4u++u3LN4494M/edreR7sYw6Fux77i3P3Ds7O995NiHbHvGmSdNbbz2e1/8/IYjnnhY5Ze3\n3viXf/3+rWe/4kX7OKXdjF53EwSkud0+NtKOG+nrvvnJzx7z5L9+0nFfP+PRp52w5tf/8/Wv\n/fDm5Se/4DNPvVuxkNvXfTI42p4fuOfbn5V70DkffeLJW57//BNHmz/69n98/bItpw+Vf7G3\nvs1lo86XxlJKv3j3G/5q/SmPfOUbupys4eO3Xvbhk4749sPPvG9u85XfuvBHk7OFl3/620dX\nf/vfO6950bGfedtPfp3SI97xx+2OM8dr7GKamEee4AA46Oz1w6u3WezeHSDy5UP+7Wc//7vX\nv2BdY8OXP/Wxr//wuns97oWfveS6N525ds8PLDv+rF/++EtnPfmMXdf+6N/+7SvbBk5//1eu\nfPfjD7/tCMX+E798xeVvft4Txn914Sc//62VD3nF//zw79bXmns+hDzHs+xVeeCe37nmhy98\n4OpLvv4fX7vol+vu++j3fv4n57301Lv+5PrzX33W564/5tmfPvv0lXv+ZOVpZ3/qWUfdcuHZ\nZ33hhn09++u//tMPnv1Hxw5s+ep//MtHPvnZG3NHveyt/3zFd/6m2OaX0vj4cd9SSq/95g/f\n+uInpV+d/75zPnDBz2950Ks/cePFn/n4a5440PrVX7/zH4Pxic199DpeAtyV/fk2c7l9bKQd\nN9K+1Y+55KoLX/vsx2z75Q8+fu6nLrt12XNe+75fXPbRwUIu7fs+GR8tpTT2gPdc9PG/fOBJ\na7/96X9423s+eP5PZl7yt99502Ftv5e0YweGDnnZG59+/3Tzl97xrg9cM93obrJWnPjeK7/2\nkced3PeDr/77+ZdefcxDnvzRb1z1t8886vY/c/xLX5FSyhf63/+kI4JDzfEa93WamEe5008/\nvV122WWXRS3Df7U+/PDDg/SYY44J0lWrom+X7e/vD9LR0Tu/zu324icp4n+1HhoaCtLBwcEg\n7evr8DBStVrtuvkSfIKj41/AC/QER9znLD7BET/vUKtFn9+emoq+nz9uG/eqlyc44l718gRH\nfEWTk9EXYv30pz8N0p/97GdBumPHjq57FbftUbwsD7bfkjPqxxdfNJNfcb/7/vaTwI3Jy0sD\np6x76Fd+/a3HdH3Y04cqvxp87u5bzp2PPh50jN5BouPf7L3sovbn/clGunham399fWHVkcur\n0e/nS0dt98V9Iw9Ycer7N/34ZXNulLFrPDB03J89wQEAS9F5z3z0Ax/4Oz8Z/23h738+9NKU\n0plvuefidQogS2ykiye/6rCjM/Rf/ld/7FWt2dmHnfPUfWmUsWs8SETPLAAAi+XVn3jZBx72\njgef/NA/ecHjDh0pXXPZ1z583oUrT/uTjz3YpxsA5sRGSkc7J+uFnT991psuK/Yd9QELI/sU\n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\nC94SqQqTt/KSAAAAAElFTkSuQmCC"
     },
     "metadata": {
      "image/png": {
       "height": 240,
       "width": 720
      }
     },
     "output_type": "display_data"
    }
   ],
   "source": [
    "options(repr.plot.width = 3 * 4, repr.plot.height = 4)\n",
    "\n",
    "# Take a nice looking image from the data\n",
    "im <- X[706, ]\n",
    "\n",
    "# Calculate edges using our own functions\n",
    "im_edge <- make_edges(calc_edge_values(im))\n",
    "\n",
    "# Calculate edges using the example\n",
    "im <- matrix(X_train[706, ], 48)\n",
    "h_edge <- im[-1, ] - im[-48, ] # horizontal\n",
    "v_edge <- im[, -1] - im[, -48] # vertical\n",
    "d_edge <- h_edge[, -1] - h_edge[, -48] # diagonal\n",
    "\n",
    "# Specify a threshold (hand tuned here on visual result)\n",
    "threshold <- .1\n",
    "\n",
    "\n",
    "layout(t(1:3))\n",
    "as_image(im)\n",
    "as_image((h_edge[, -1] < threshold) & (v_edge[-1, ] < threshold) & (d_edge < threshold / 2), 47)\n",
    "mtext(\"edge pixels example\")\n",
    "as_image(im_edge$edge_h[, -1] & im_edge$edge_v[-1, ] & im_edge$edge_d1 & im_edge$edge_d2, 47)\n",
    "mtext(\"edge pixels calculate by us\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "d6c610c5",
   "metadata": {
    "papermill": {
     "duration": 0.019881,
     "end_time": "2023-12-10T23:30:32.048615",
     "exception": false,
     "start_time": "2023-12-10T23:30:32.028734",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### 3.2.3 Extracting Edge features\n",
    "The edge functions are working correctly so we can extract the edges from the data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 10,
   "id": "5160cf43",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:32.093816Z",
     "iopub.status.busy": "2023-12-10T23:30:32.091926Z",
     "iopub.status.idle": "2023-12-10T23:30:52.817641Z",
     "shell.execute_reply": "2023-12-10T23:30:52.815600Z"
    },
    "papermill": {
     "duration": 20.753364,
     "end_time": "2023-12-10T23:30:52.821300",
     "exception": false,
     "start_time": "2023-12-10T23:30:32.067936",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "'64 Frey &amp; Slate Features'"
      ],
      "text/latex": [
       "'64 Frey \\& Slate Features'"
      ],
      "text/markdown": [
       "'64 Frey &amp; Slate Features'"
      ],
      "text/plain": [
       "[1] \"64 Frey & Slate Features\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/html": [
       "'20 Edge-Based Histogram Features'"
      ],
      "text/latex": [
       "'20 Edge-Based Histogram Features'"
      ],
      "text/markdown": [
       "'20 Edge-Based Histogram Features'"
      ],
      "text/plain": [
       "[1] \"20 Edge-Based Histogram Features\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# GET EDGES (TWO TYPES) -----------------------------------\n",
    "# Compute edges for all images\n",
    "X_edges_values <- apply(X, 1, calc_edge_values)\n",
    "# Compute logical version of edges for all images\n",
    "X_edges <- lapply(X_edges_values, make_edges)\n",
    "\n",
    "# COMPUTING FEATURES ON EDGES ------------------------------\n",
    "# Compute frey & slate features for all images\n",
    "frey_slate_features <- sapply(X_edges, calc_frey_slate_feat) %>% t()\n",
    "paste(dim(frey_slate_features)[2], \"Frey & Slate Features\")\n",
    "# Compute histogram features for all images\n",
    "edge_hist_features <- sapply(X_edges, calc_hist_feat) %>% t()\n",
    "paste(dim(edge_hist_features)[2], \"Edge-Based Histogram Features\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "4bb95dec",
   "metadata": {
    "papermill": {
     "duration": 0.069354,
     "end_time": "2023-12-10T23:30:52.910607",
     "exception": false,
     "start_time": "2023-12-10T23:30:52.841253",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.3 HOG features \n",
    "In this section, we leverage the Histogram of Oriented Gradients (HOG) technique, a renowned feature descriptor in computer vision and image processing. By quantifying gradient orientations in localized regions of the image, we gain crucial information for effective object detection. Using these features was inspired by Carcagnì et al. (2015), who recommended these type of features. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "f3f75a55",
   "metadata": {
    "papermill": {
     "duration": 0.019733,
     "end_time": "2023-12-10T23:30:52.949799",
     "exception": false,
     "start_time": "2023-12-10T23:30:52.930066",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.3.1 HOG features Helper functions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 11,
   "id": "fba1775c",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:53.012504Z",
     "iopub.status.busy": "2023-12-10T23:30:53.009515Z",
     "iopub.status.idle": "2023-12-10T23:30:53.038345Z",
     "shell.execute_reply": "2023-12-10T23:30:53.036108Z"
    },
    "papermill": {
     "duration": 0.067189,
     "end_time": "2023-12-10T23:30:53.042018",
     "exception": false,
     "start_time": "2023-12-10T23:30:52.974829",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "compute_gradients <- function(image) {\n",
    "  # Sobel operators for gradient computation\n",
    "  gx <- matrix(c(-1, 0, 1, -2, 0, 2, -1, 0, 1), nrow = 3, byrow = TRUE)\n",
    "  gy <- t(gx)\n",
    "\n",
    "  # Initialize matrices for gradients\n",
    "  Gx <- matrix(0, nrow = nrow(image), ncol = ncol(image))\n",
    "  Gy <- matrix(0, nrow = nrow(image), ncol = ncol(image))\n",
    "\n",
    "  # Compute gradients pixel by pixel\n",
    "  for (i in 2:(nrow(image) - 1)) {\n",
    "    for (j in 2:(ncol(image) - 1)) {\n",
    "      # Compute gradient components using Sobel operators\n",
    "      subset <- image[(i - 1):(i + 1), (j - 1):(j + 1)]\n",
    "      Gx[i, j] <- sum(subset * gx)\n",
    "      Gy[i, j] <- sum(subset * gy)\n",
    "    }\n",
    "  }\n",
    "\n",
    "  # Compute gradient magnitude and angle\n",
    "  magnitude <- sqrt(Gx^2 + Gy^2)\n",
    "  angle <- atan2(Gy, Gx) * (180 / pi)\n",
    "\n",
    "  return(list(magnitude = magnitude, angle = angle))\n",
    "}\n",
    "\n",
    "compute_histogram <- function(magnitude, angle, num_bins = 9) {\n",
    "  # Initialize histogram\n",
    "  histogram <- rep(0, num_bins)\n",
    "\n",
    "  # Compute histogram\n",
    "  bin_width <- 180 / num_bins\n",
    "  angle <- angle %% 180 # Ensure angles are in [0, 180) range\n",
    "  for (i in 1:length(angle)) {\n",
    "    if (!is.na(angle[i])) { # Skip NA values\n",
    "      bin <- floor(angle[i] / bin_width) + 1\n",
    "      histogram[bin] <- histogram[bin] + magnitude[i]\n",
    "    }\n",
    "  }\n",
    "\n",
    "  return(histogram)\n",
    "}\n",
    "\n",
    "compute_block_descriptor <- function(histogram, block_size = 2) {\n",
    "  num_bins <- length(histogram)\n",
    "  num_cells <- block_size^2\n",
    "\n",
    "  # Initialize block descriptor\n",
    "  block_descriptor <- rep(0, num_bins * num_cells)\n",
    "\n",
    "  # Populate block descriptor\n",
    "  block_descriptor[1:num_bins] <- histogram\n",
    "\n",
    "  # L2 normalization\n",
    "  norm_factor <- sqrt(sum(block_descriptor^2) + 1e-5)\n",
    "  block_descriptor <- block_descriptor / norm_factor\n",
    "\n",
    "  return(block_descriptor)\n",
    "}\n",
    "\n",
    "# FUNCTION FOR EXTRACTING THE HOG_FEATURES --------------\n",
    "extract_hog_features <- function(image_as_row, cell_size = 8, block_size = 2, num_bins = 9) {\n",
    "  image <- image_as_row %>%\n",
    "    unlist() %>%\n",
    "    matrix(48)\n",
    "\n",
    "  # Compute gradients\n",
    "  gradients <- compute_gradients(image)\n",
    "\n",
    "  # Define cell grid\n",
    "  num_cells_x <- floor(ncol(image) / cell_size)\n",
    "  num_cells_y <- floor(nrow(image) / cell_size)\n",
    "\n",
    "  # Initialize HOG features\n",
    "  hog_features <- numeric()\n",
    "\n",
    "  for (i in 1:num_cells_y) {\n",
    "    for (j in 1:num_cells_x) {\n",
    "      start_x <- (j - 1) * cell_size + 1\n",
    "      start_y <- (i - 1) * cell_size + 1\n",
    "      end_x <- start_x + cell_size - 1\n",
    "      end_y <- start_y + cell_size - 1\n",
    "\n",
    "      # Extract cell region\n",
    "      cell_magnitude <- gradients$magnitude[start_y:end_y, start_x:end_x]\n",
    "      cell_angle <- gradients$angle[start_y:end_y, start_x:end_x]\n",
    "\n",
    "      # Compute cell histogram\n",
    "      cell_histogram <- compute_histogram(cell_magnitude, cell_angle, num_bins)[1:9]\n",
    "\n",
    "      # Append cell histogram to features\n",
    "      hog_features <- c(hog_features, cell_histogram)\n",
    "    }\n",
    "  }\n",
    "\n",
    "  # Reshape HOG features into block descriptors\n",
    "  num_blocks_x <- num_cells_x - block_size + 1\n",
    "  num_blocks_y <- num_cells_y - block_size + 1\n",
    "\n",
    "  for (i in 1:num_blocks_y) {\n",
    "    for (j in 1:num_blocks_x) {\n",
    "      start_idx <- (i - 1) * num_blocks_x + j\n",
    "      end_idx <- start_idx + block_size^2 - 1\n",
    "      block_descriptor <- compute_block_descriptor(\n",
    "        hog_features[start_idx:end_idx],\n",
    "        block_size\n",
    "      )\n",
    "\n",
    "      hog_features[start_idx:end_idx] <- block_descriptor\n",
    "    }\n",
    "  }\n",
    "\n",
    "  return(hog_features)\n",
    "}\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "fe586589",
   "metadata": {
    "papermill": {
     "duration": 0.019485,
     "end_time": "2023-12-10T23:30:53.084749",
     "exception": false,
     "start_time": "2023-12-10T23:30:53.065264",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.3.2 Testing HOG features"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 12,
   "id": "2945952c",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:53.128999Z",
     "iopub.status.busy": "2023-12-10T23:30:53.126972Z",
     "iopub.status.idle": "2023-12-10T23:30:53.309116Z",
     "shell.execute_reply": "2023-12-10T23:30:53.305644Z"
    },
    "papermill": {
     "duration": 0.21623,
     "end_time": "2023-12-10T23:30:53.320626",
     "exception": false,
     "start_time": "2023-12-10T23:30:53.104396",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "image/png": "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\n37OkW3Fhf0/UwvXd72Nechl78yW9jK1r25Y0Ly7pGuz7u+RN6WPuvsA+o75WS56Nb1Sj56w+\nsP7p3rYXtF5m+/Ho29QfnUv3+vfv9rYXL16MdEkv4/r16yPt69xVdnfeeWekv/zLvxzpLbfc\nEunBgwcjPXbs2Kpo9nu05qvRF2rKUsCdO3fGhr3WTXl/+8GYvRpbt25dFe3YsaO3XbO+BdPc\nU3f69OlV0alTp2LDJZ27fY/e9a53RTrLf6ABAGCAARoAAAYYoAEAYIABGgAABhigAQBggAEa\nAAAGGKABAGCAARoAAAYYoAEAYEB14XTdVPfodJHVmTNnIu1emW5A7FKoPqrec1dG9Z5nm8x6\n52v+6SUNat0J12ZblOLh6c6hS9qeGJdrYfNinO+SurjettO+kkta/fparblWc/aoum+sj6qb\nU5f0YF3SJsIldZKtH49eKrv6q1ezyy+/PNIlH53+nHUTYetbfOjQoUg3b94c6caNGyPdtWvX\nmve8ZcuWSD/2sY9Funv37kj7VYr005/+dGw4zRUYxx08fvx47/kLX/jCqqgnitnm43Pnzq2K\n+nRmv3T9DrZ+2uPAenKb5poI48PRq/eSL86SmWGW/0ADAMAAAzQAAAwwQAMAwAADNAAADDBA\nAwDAAAM0AAAMMEADAMAAAzQAAAwwQAMAwIAqdmpLGra6Mqr33EVWrbdd0qDWTTmzrX5Lmgij\nu2vJ+Xah1GwDU4tyoCUNiEt6+6bsOes2o9k9xx8suUd9rXrbbn5a0srZ+qiWXI2uqes72Fdy\nSeHfJe3B6sP+z//5P695z90I2H1jS27xddddF+nZs2cjjda3admS1QtLf866ifCpp55a4zHN\nLdE///M/H+nDDz8cad/9K6+8MtL169dHGnfhySefjA2naTp58mSk8dT1+ztl42M/rn2y0zRt\n2LCh/2CVp59+uv/gU5/61KqoH8hp7v2Nxb+/GrN7juvcj1yvogu/zkv4DzQAAAwwQAMAwAAD\nNAAADDBAAwDAAAM0AAAMMEADAMAAAzQAAAwwQAMAwAADNAAADKjurm6dOX/+fKTdDXPZZZdF\n2gVL3QzUJUl9Rl031UfV6WwT0pKaw2hg6g6ebm7ra9XpkvPtY+7nqs9otpEodt577nTKh7bf\nhX7alzyxFy9ejPT06dORXnXVVZF2+Vbfha6L6/Pta9XH3HehC/+WHNVC3fm3xJIFvG9xl7dt\n3bo10i1btkTaTXXHjx+P9MyZM5H2TewX7cKFC2vec1/JfvC2bdsW6cte9rJI+zU8ceJEpO3I\nkSNr3m1f53hiZ1f+7s8Lsyt/PO1vfOMbY8M+2Wma9u7duyr6vu/7vt62+z5DP3LT3GclnvZ+\n5HrBmb0Ll47/QAMAwAADNAAADDBAAwDAAAM0AAAMMEADAMAAAzQAAAwwQAMAwAADNAAADDBA\nAwDAgGpw6ZKkLsHqbZf02HVFVjeodeHQzp07I13SZDbbzNdVZ11KdPbs2TVE01z3Tx9zdzvN\nNj+FJZ1//dRt2rSpf3rz5s2roh07dsSGu3fv7j1HK1g/OUu6Bs+dO7fm9Pnnn4+0n6t9+/ZF\nevTo0Uj77e41p5/Yyy+/PNJ+u/t57pf3kurL1ekS/Vj27x4+fDjS3/md31nznpec76WrOL10\nH8q+C512ZW+nXULcr2HUDfaqMs3dhTjf2QcjrnP/6OyeY/Mlj9w0TYcOHVoV/dqv/Vpv28v7\nn//5n6+Knnnmmd5zNxHGPerHpg+4r2S/CP/lv/yXSGerXv0HGgAABhigAQBggAEaAAAGGKAB\nAGCAARoAAAYYoAEAYIABGgAABhigAQBggAEaAAAGVNtNN2x1hdKSRrHuV+s933nnnZHu2rUr\n0u6E27hxY6QbNmyItBsQZ/+gT/nkyZOrov3798eGX/rSlyI9duxYpGfOnFlzOmU5UNd6dZ/c\n1VdfHenNN9/cR7V9+/ZV0TXXXBMb9nM1fR0PwCrdF9i9m/2WnTp1KtIulOrOzr5WDz30UKRf\n+MIXIu0KtH42WlevdSFc6x6shfrA7rvvvkiX1IX2C/7UU09F+sUvfjHSvly9RLclH6yuSes9\nd6Vcv6RdFtvXqo+qP2f96e9lp383lp3ZN2XNhXOzj3rsuX+0T3bKu7+kZrL/YHbbK664ItI3\nvelNa4i+5pOf/GSka777nfbr2V+NhfwHGgAABhigAQBggAEaAAAGGKABAGCAARoAAAYYoAEA\nYIABGgAABhigAQBggAEaAAAGVEnShQsXasssWOqWnS5Yimq9aZpuuummNR/Vvn37Iu3Wty7v\n6fPt2qdpmjZt2hTpli1bIt22bduq6Prrr48Nu32t66b6HnXH4TRNR48eXRU9//zzsWFfyT7f\n2aa6Z555ZlV05MiR2LCvxpSVkN342Fdj8+bNkXY7Zr/dnXYT4Stf+cpIX/GKV0TaDYgPP/xw\n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\nNe/55ptv7m37ib3rrrtWRefPn+8992IYI1Z/92cbAUN/Jd/1rnetec+T/0ADAMAQAzQAAAww\nQAMAwAADNAAADDBAAwDAAAM0AAAMMEADAMAAAzQAAAwwQAMAwICqFOpCqS4c+vKXvxzppWsi\n7CKc7rPpJsJHHnkk0q6M6padaa7IsC9mtJF111H3Mx06dCjSI0eORDpbc/X000+viroxrivB\nrr/++khn+wLX3JPUxzxll+SNN94YG+7evTvSrprr1qh+B8+ePRtpv6Hd/NQNW31Us9c59Hq1\npInw4sWLazymxfpF6yrKLn7rS90Xs9P+rPSlPnHiRKS9Tvb59k3spbLLRJ944olIP/CBD0T6\n4IMPRnrq1KlI+y70p7Bf/35Z+sMRd3D2K9kdlpHO9tjFtu9+97tjw17rprkPVuhJZsr7e/XV\nV/e2fX/jwzHb29f3KOacJWt7Lyn93V/ScTj5DzQAAAwxQAMAwAADNAAADDBAAwDAAAM0AAAM\nMEADAMAAAzQAAAwwQAMAwAADNAAADKhWvyVlVEuaCLvoqFvQWnezdZtgn2838/UZTXOXuisS\nb7rpplXR5z//+diw78KePXsi3blzZ6SznVJRGdgNTKdPn460C5aOHj3aRxUdWlEl+PWIe7Rr\n167Y8Nlnn420S866eq2fya5827BhQ6Rd29a/229oF+8tqV677LLLIu0r2ek3UJe2Lil97BvR\ne+6usi4V6/R//s//Gek73/nOS/S7fUbXXHNNpF1E+vGPfzzSXiqX9EG2XmbX3DR55syZ/t1+\nSWN5/+M//uPe8+OPP74qWtKcOuV71NvOrirRQ7ljx47e9vjx45HGR/a9731v7/mOO+6INA5s\nySray9GSR32W/0ADAMAAAzQAAAwwQAMAwAADNAAADDBAAwDAAAM0AAAMMEADAMAAAzQAAAww\nQAMAwICqqurin+536Tay7insHrs+qu4p7Aqlbgbatm1bpN0Yt379+kinuSqdixcvRnr55Zev\niu666641/+iXvvSlSB999NE173nKrqPuous72LVeu3fv7qOKP7j66qtjw64Ea1EoNWU54jTX\n3dXPcx9zv2Xd6td3sOvx4mGe5o65y/OWFOD1avYN1C9aH/ZVV10VaV+uJV2DnfaD1+16ved+\n/fs17BW4r3NXrH3Lt3xLpHv37l3znvuMutK1r2R/vm+99dZIb7vttlXRbBNhH3MsSt2r2npl\n6PVqmqZNmzatirrdtm/fNE2/+7u/uyrqr9U096GMj2y/gNPc+xtXo7ucW3+PTp48ueY9z/If\naAAAGGCABgCAAQZoAAAYYIAGAIABBmgAABhggAYAgAEGaAAAGGCABgCAAQZoAAAYUK1gV1xx\nRW2ZjWJdZdTFTl101M1Afcy9525Qu/LKKyNdUr41zRXs9eWKU+6qqj6q7nXrtO9R/3SXq/We\nu7evL/KUNZbdddT9l1Peo+5J6jPqO9j9l/0u9HvUV6PvUW/bd7/T3nO/C0u2/QbqB+DcuXOR\nvulNb4r0wx/+cKR9ubqurMvb+uHpBsS+Ta985Ssj3bx585r3fPz48Ugv3YvWV6PvQi/g/XHv\nT2Evs1Gw1xdqmnty4nz7yz7lleyL3OWI0zTdfffdq6Ju873nnnt6zz/3cz+3KtqxY0dvG42A\n0zQdPnx4VTTbFnngwIFIf/VXf3VV9H/+z/+JDftFaEsmitnf9R9oAAAYYIAGAIABBmgAABhg\ngAYAgAEGaAAAGGCABgCAAQZoAAAYYIAGAIABBmgAABhQhUNLuug6fe655yLt4r0lNVfdddQt\nOxs3boz0sssui3S+zyZPqpuuostq3bp1sWHXa124cCHSPqO++715Pxutj3m2RSkOu4vKuvNv\nym6nZ599NjbsSrAlT13fo35ylryhbUlr1JK0r8aS5sVLakkhaN/ibptb0pDXab/CS873zjvv\njLSL0Po13LVrV6T79u2LtPXvdudf1+91hV6/4FddddWa0+jOvO2222LDaZqeeOKJSI8dO7Yq\n6tOZciHduXNnbHjffff1nvfv378q2rJlS2z4Qz/0Q73nOOZeRae56tzt27evivrmTnP9pt/5\nnd+5KvrEJz4RG/YB94t/0003Rbqk43DyH2gAABhigAYAgAEGaAAAGGCABgCAAQZoAAAYYIAG\nAIABBmgAABhggAYAgAEGaAAAGFBFR93R0n1js110axZVRrP6mLuvqLvotm7dGmm3zU1zrWDd\n3RU9hd2Q162NS7rZugRryhuxYcOG2LA7h7pea7afKS5XP3VPP/107zk277Kx/t1+bLrTMeqm\nprm7342e/bj2XViy5nRbVV/Jfhd6ZYgq0NmjWmhJQebNN98c6R133BFp17L2S9q3eEnJZbcn\n9svSpZ69sPSe/+iP/ijSe+65J9IlRaT9bPSV/OhHPxppN+O2WBx+4Ad+oLftpSOuxmy77Q//\n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\nb88AAAAASUVORK5CYII="
     },
     "metadata": {
      "image/png": {
       "height": 240,
       "width": 480
      }
     },
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Example:\n",
    "gradients_image <- X[706, ] %>%\n",
    "  unlist() %>%\n",
    "  matrix(nrow = 48, ncol = 48) %>%\n",
    "  compute_gradients()\n",
    "\n",
    "options(repr.plot.width = 2 * 4, repr.plot.height = 4)\n",
    "layout(t(1:2))\n",
    "as_image(gradients_image$magnitude)\n",
    "as_image(gradients_image$angle)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "47e49726",
   "metadata": {
    "papermill": {
     "duration": 0.022195,
     "end_time": "2023-12-10T23:30:53.366321",
     "exception": false,
     "start_time": "2023-12-10T23:30:53.344126",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.3.3 Extracting HOG features"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 13,
   "id": "284bfaa3",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:30:53.419799Z",
     "iopub.status.busy": "2023-12-10T23:30:53.417639Z",
     "iopub.status.idle": "2023-12-10T23:31:41.992849Z",
     "shell.execute_reply": "2023-12-10T23:31:41.990799Z"
    },
    "papermill": {
     "duration": 48.631448,
     "end_time": "2023-12-10T23:31:42.021127",
     "exception": false,
     "start_time": "2023-12-10T23:30:53.389679",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "'324 Histogram of Oriented Gradients Features'"
      ],
      "text/latex": [
       "'324 Histogram of Oriented Gradients Features'"
      ],
      "text/markdown": [
       "'324 Histogram of Oriented Gradients Features'"
      ],
      "text/plain": [
       "[1] \"324 Histogram of Oriented Gradients Features\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# APPLYING THE FUNCTION TO EXTRACT THE FEATURES -------------------------\n",
    "options(warn = -1)\n",
    "features_hog <- apply(X, 1, extract_hog_features) %>% t()\n",
    "paste(ncol(features_hog), \"Histogram of Oriented Gradients Features\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a2856d1e",
   "metadata": {
    "papermill": {
     "duration": 0.020455,
     "end_time": "2023-12-10T23:31:42.061937",
     "exception": false,
     "start_time": "2023-12-10T23:31:42.041482",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 3.4 Power Spectral Density (PSD)\n",
    "The function calc_psd_features extracts Power Spectral Density (PSD) features from image rows. PSD is a powerful tool used in signal processing to understand the frequency content of a signal. In the context of image analysis, PSD provides valuable information about the distribution of frequencies in an image, which can be useful for tasks like emotion recognition."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "15e51483",
   "metadata": {
    "papermill": {
     "duration": 0.021625,
     "end_time": "2023-12-10T23:31:42.103975",
     "exception": false,
     "start_time": "2023-12-10T23:31:42.082350",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.4.1 PSD features Helper functions"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 14,
   "id": "ac92b520",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:31:42.150993Z",
     "iopub.status.busy": "2023-12-10T23:31:42.149078Z",
     "iopub.status.idle": "2023-12-10T23:31:42.166247Z",
     "shell.execute_reply": "2023-12-10T23:31:42.164114Z"
    },
    "papermill": {
     "duration": 0.044194,
     "end_time": "2023-12-10T23:31:42.169222",
     "exception": false,
     "start_time": "2023-12-10T23:31:42.125028",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "calc_psd_features <- function(im_row, dim = sqrt(length(im_row))) {\n",
    "  # Take only the central 30x30 region of the image\n",
    "  # This region is likely to contain the most relevant facial features for emotion prediction,\n",
    "  # and we want to decrease runtime, because this part can take very long.\n",
    "  t_image <- im_row %>%\n",
    "    unlist() %>%\n",
    "    matrix(dim) %>%\n",
    "    as_tibble() %>%\n",
    "    select(10:39) %>%\n",
    "    slice(10:39)\n",
    "\n",
    "  # calculate Power Spectral Density (PSD) features for each row of the image\n",
    "  psd_features_row <- t_image %>%\n",
    "    rowwise() %>%\n",
    "    transmute(\n",
    "      spec_vec = list(spectrum(c_across(1:30), plot = FALSE)$spec), # Compute PSD (won't be returned)\n",
    "      mean_psd = mean(spec_vec), # Calculate the mean of PSD\n",
    "      median_psd = median(spec_vec), # Calculate the median of PSD\n",
    "      sd_psd = sd(spec_vec) # Calculate the standard deviation of PSD\n",
    "    ) %>%\n",
    "    ungroup()\n",
    "\n",
    "  # Reshape the data to wide format because that is how we need the features\n",
    "  psd_features_wide <- psd_features_row[, c(\"mean_psd\", \"median_psd\", \"sd_psd\")] %>%\n",
    "    mutate(id = paste0(\"row\", 1:30)) %>%\n",
    "    pivot_wider(\n",
    "      names_from = id,\n",
    "      values_from = c(mean_psd, median_psd, sd_psd)\n",
    "    ) %>%\n",
    "    data.frame()\n",
    "  return(unlist(psd_features_wide))\n",
    "}"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "017d744b",
   "metadata": {
    "papermill": {
     "duration": 0.021208,
     "end_time": "2023-12-10T23:31:42.212045",
     "exception": false,
     "start_time": "2023-12-10T23:31:42.190837",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 3.4.2 Extracting PSD features"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 15,
   "id": "fd92dc19",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:31:42.260163Z",
     "iopub.status.busy": "2023-12-10T23:31:42.258317Z",
     "iopub.status.idle": "2023-12-10T23:39:53.997100Z",
     "shell.execute_reply": "2023-12-10T23:39:53.994994Z"
    },
    "papermill": {
     "duration": 491.790596,
     "end_time": "2023-12-10T23:39:54.024489",
     "exception": false,
     "start_time": "2023-12-10T23:31:42.233893",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "90 Power Spectral Density Features"
     ]
    }
   ],
   "source": [
    "# APPLYING THE FUNCTION TO EXTRACT THE FEATURES -------------------------\n",
    "features_psd <- apply(X, 1, calc_psd_features) %>% t()\n",
    "cat(ncol(features_psd), \"Power Spectral Density Features\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c32775e6",
   "metadata": {
    "papermill": {
     "duration": 0.020728,
     "end_time": "2023-12-10T23:39:54.065847",
     "exception": false,
     "start_time": "2023-12-10T23:39:54.045119",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    " <h1 id = features style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    4. Model Fitting & Evaluation\n",
    "</h1>\n",
    "\n",
    "\n",
    "Now, that all the features have been extracted, we can prepare the data for the model fitting and subseqeuntly evaluate different models.\n",
    "\n",
    "## 4.1 Preparing Feature Dataset\n",
    "Preparing our features data set consists of \n",
    "* merging the different feature data\n",
    "* cleaning the feature set \n",
    "* splitting the feature data set into training and test data\n",
    "\n",
    "#### 4.1.1 Merging Features\n",
    "Combining all the features into one big dataframe"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 16,
   "id": "37ec727e",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:39:54.112466Z",
     "iopub.status.busy": "2023-12-10T23:39:54.110695Z",
     "iopub.status.idle": "2023-12-10T23:39:54.168428Z",
     "shell.execute_reply": "2023-12-10T23:39:54.165816Z"
    },
    "papermill": {
     "duration": 0.086484,
     "end_time": "2023-12-10T23:39:54.172959",
     "exception": false,
     "start_time": "2023-12-10T23:39:54.086475",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Before cleaning we have 602 features total"
     ]
    }
   ],
   "source": [
    "features_all_combined <- cbind(\n",
    "  features_col_row_means, # Row & Col Means Features\n",
    "  features_image_sum_stats, # Image Sum Statistics Features\n",
    "  frey_slate_features, # Frey & Slate Features\n",
    "  edge_hist_features, # Edge-Based Histogram Features\n",
    "  features_hog, # Histogram of Oriented Gradients Features\n",
    "  features_psd # Power Spectral Density Features\n",
    ") \n",
    "\n",
    "cat(\"Before cleaning we have\", ncol(features_all_combined), \"features total\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "859a9b59",
   "metadata": {
    "papermill": {
     "duration": 0.021482,
     "end_time": "2023-12-10T23:39:54.215658",
     "exception": false,
     "start_time": "2023-12-10T23:39:54.194176",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.1.2 Cleaning Features\n",
    "Removing near zero variance features and highly correlated features"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 17,
   "id": "42f15c48",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:39:54.261153Z",
     "iopub.status.busy": "2023-12-10T23:39:54.259295Z",
     "iopub.status.idle": "2023-12-10T23:40:06.985115Z",
     "shell.execute_reply": "2023-12-10T23:40:06.982891Z"
    },
    "papermill": {
     "duration": 12.751673,
     "end_time": "2023-12-10T23:40:06.987837",
     "exception": false,
     "start_time": "2023-12-10T23:39:54.236164",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/html": [
       "'We have removed 22 features because they have near zero variance.'"
      ],
      "text/latex": [
       "'We have removed 22 features because they have near zero variance.'"
      ],
      "text/markdown": [
       "'We have removed 22 features because they have near zero variance.'"
      ],
      "text/plain": [
       "[1] \"We have removed 22 features because they have near zero variance.\""
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "We have removed 86 features because they were highly correlated.After cleaning we have 494 features total"
     ]
    }
   ],
   "source": [
    "# REMOVING NEAR ZERO VARIANCE FEATURES ---------------------\n",
    "# Convert matrix to tibble\n",
    "features <- features_all_combined %>%\n",
    "  as_tibble()\n",
    "\n",
    "# Parallel Processing\n",
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "# Compute Near-Zero-Variance features\n",
    "nzv_features <- caret::nearZeroVar(features,\n",
    "  freqCut = 95 / 5,\n",
    "  names = TRUE,\n",
    "  allowParallel = TRUE\n",
    ")\n",
    "# Remove near zero variance features\n",
    "features <- features %>%\n",
    "  select(-all_of(nzv_features))\n",
    "\n",
    "paste(\"We have removed\", length(nzv_features), \"features because they have near zero variance.\")\n",
    "\n",
    "\n",
    "# REMOVING HIHGLY CORRELATED FEATURES ------------------------------------\n",
    "# Compute highly correlating features\n",
    "high_cor_feat <- caret::findCorrelation(cor(features), cutoff = 0.98, names = TRUE)\n",
    "\n",
    "# Remove highly correlating features\n",
    "features <- features %>%\n",
    "  select(-all_of(high_cor_feat))\n",
    "\n",
    "# RETURN RESULTS\n",
    "cat(\"We have removed\", length(high_cor_feat), \"features because they were highly correlated.\")\n",
    "cat(\"After cleaning we have\", ncol(features), \"features total\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "6f7c3f7f",
   "metadata": {
    "papermill": {
     "duration": 0.021388,
     "end_time": "2023-12-10T23:40:07.035129",
     "exception": false,
     "start_time": "2023-12-10T23:40:07.013741",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.1.3 Splitting Feature Data Set into Training and Test Data\n",
    "\n",
    "We previously merged test and training data to simultaneously compute features for the entire data set.\n",
    "Now, in order to fit our models, we need to separate the data into training and test data again."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 18,
   "id": "0543412d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:40:07.082288Z",
     "iopub.status.busy": "2023-12-10T23:40:07.080119Z",
     "iopub.status.idle": "2023-12-10T23:40:07.191356Z",
     "shell.execute_reply": "2023-12-10T23:40:07.189045Z"
    },
    "papermill": {
     "duration": 0.138226,
     "end_time": "2023-12-10T23:40:07.194499",
     "exception": false,
     "start_time": "2023-12-10T23:40:07.056273",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "# Getting train-data back again\n",
    "# Select training set\n",
    "train <- features[train_index, ]\n",
    "\n",
    "# Select test set\n",
    "test <- features[-train_index, ]\n",
    "\n",
    "# Make Cross Validation\n",
    "trCntrl <- trainControl(\"cv\", 5, allowParallel = TRUE, savePredictions = \"final\")"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "b9de6172",
   "metadata": {
    "papermill": {
     "duration": 0.021225,
     "end_time": "2023-12-10T23:40:07.237720",
     "exception": false,
     "start_time": "2023-12-10T23:40:07.216495",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 4.2 Model Fitting\n",
    "\n",
    "To figure out which model provides the best trade off between bias and variance, between accuracy and flexibility, one strategy is to fit both a flexible and a more rigid model and determine from CV error which direction on the flexiblity axis we should go to avoid overtraining.\n",
    "\n",
    "We'll consider classification trees and random forests here. Random forests are probably the least susceptible to overtraining and is considered one of the best \"off the shelf\" machine learning algorithms in the sense that they require little expertise in application, and easily perform well without tuning. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "bfc7d625",
   "metadata": {
    "papermill": {
     "duration": 0.021145,
     "end_time": "2023-12-10T23:40:07.282174",
     "exception": false,
     "start_time": "2023-12-10T23:40:07.261029",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.1 QDA"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 19,
   "id": "9bc5085d",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:40:07.330433Z",
     "iopub.status.busy": "2023-12-10T23:40:07.328499Z",
     "iopub.status.idle": "2023-12-10T23:40:26.231858Z",
     "shell.execute_reply": "2023-12-10T23:40:26.223231Z"
    },
    "papermill": {
     "duration": 18.934485,
     "end_time": "2023-12-10T23:40:26.238996",
     "exception": false,
     "start_time": "2023-12-10T23:40:07.304511",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Quadratic Discriminant Analysis \n",
       "\n",
       "2538 samples\n",
       " 494 predictor\n",
       "   4 classes: 'anger', 'disgust', 'happy', 'sad' \n",
       "\n",
       "Pre-processing: principal component signal extraction (494), centered\n",
       " (494), scaled (494) \n",
       "Resampling: Cross-Validated (5 fold) \n",
       "Summary of sample sizes: 2030, 2030, 2031, 2030, 2031 \n",
       "Resampling results:\n",
       "\n",
       "  Accuracy   Kappa    \n",
       "  0.8155982  0.7363981\n"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "fit_qda <- train(train, y, method='qda', trControl=trCntrl, preProcess=\"pca\")\n",
    "fit_qda\n",
    "qda_accuracy <- max(fit_qda$results$Accuracy)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "a894e9ba",
   "metadata": {
    "papermill": {
     "duration": 0.028688,
     "end_time": "2023-12-10T23:40:26.329672",
     "exception": false,
     "start_time": "2023-12-10T23:40:26.300984",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.2 Multinomial Lasso Regression"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 20,
   "id": "87f02761",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:40:26.380540Z",
     "iopub.status.busy": "2023-12-10T23:40:26.378599Z",
     "iopub.status.idle": "2023-12-10T23:40:46.946099Z",
     "shell.execute_reply": "2023-12-10T23:40:46.943873Z"
    },
    "papermill": {
     "duration": 20.598856,
     "end_time": "2023-12-10T23:40:46.950219",
     "exception": false,
     "start_time": "2023-12-10T23:40:26.351363",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "\n",
       "Call:  glmnet::cv.glmnet(x = as.matrix(train), y = factor(y), type.measure = \"class\",      nfolds = 5, family = \"multinomial\", alpha = 1, standardize = TRUE) \n",
       "\n",
       "Measure: Misclassification Error \n",
       "\n",
       "     Lambda Index Measure SE Nonzero\n",
       "min 0.00281    51  0.0217  0      82\n",
       "1se 0.00281    51  0.0217  0      82"
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
      "---\n",
      "The Multinomial Lasso Regression yields a training accuracy of: 0.978 (95% CI: [0.978; 0.978])\n",
      "82 predictor coefficients have been preserved and not set to zero."
     ]
    }
   ],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "# Performing lasso regression\n",
    "fit_lasso <- glmnet::cv.glmnet(\n",
    "  as.matrix(train),\n",
    "  factor(y),\n",
    "  family = \"multinomial\",\n",
    "  nfolds = 5,\n",
    "  alpha = 1,\n",
    "  type.measure = \"class\",\n",
    "  standardize = TRUE\n",
    ")\n",
    "\n",
    "fit_lasso\n",
    "\n",
    "# Measure of Accuracy = 1 - Misclassification Error\n",
    "lasso_accuracy <- 1 - fit_lasso$cvm[fit_lasso$lambda == fit_lasso$lambda.min]\n",
    "lasso_lo <- 1 - fit_lasso$cvlo[fit_lasso$lambda == fit_lasso$lambda.min]\n",
    "lasso_up <- 1 - fit_lasso$cvup[fit_lasso$lambda == fit_lasso$lambda.min]\n",
    "lasso_nzero <- fit_lasso$nzero[fit_lasso$lambda == fit_lasso$lambda.min]\n",
    "\n",
    "cat(\"\\n---\\nThe Multinomial Lasso Regression yields a training accuracy of: \", round(lasso_accuracy, 3),\n",
    "  \" (95% CI: [\", round(lasso_lo, 3), \"; \", round(lasso_up, 3), \"])\\n\",\n",
    "  sep = \"\"\n",
    ")\n",
    "cat(lasso_nzero, \"predictor coefficients have been preserved and not set to zero.\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "424b9dc4",
   "metadata": {
    "papermill": {
     "duration": 0.022797,
     "end_time": "2023-12-10T23:40:46.996324",
     "exception": false,
     "start_time": "2023-12-10T23:40:46.973527",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.3 Multinomial Logistic Regression"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 21,
   "id": "0dcd1c30",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:40:47.050434Z",
     "iopub.status.busy": "2023-12-10T23:40:47.048480Z",
     "iopub.status.idle": "2023-12-10T23:41:38.858941Z",
     "shell.execute_reply": "2023-12-10T23:41:38.855623Z"
    },
    "papermill": {
     "duration": 51.858968,
     "end_time": "2023-12-10T23:41:38.882944",
     "exception": false,
     "start_time": "2023-12-10T23:40:47.023976",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "glmnet \n",
       "\n",
       "2538 samples\n",
       " 494 predictor\n",
       "   4 classes: 'anger', 'disgust', 'happy', 'sad' \n",
       "\n",
       "No pre-processing\n",
       "Resampling: Cross-Validated (5 fold) \n",
       "Summary of sample sizes: 2031, 2030, 2030, 2030, 2031 \n",
       "Resampling results across tuning parameters:\n",
       "\n",
       "  alpha  lambda        Accuracy   Kappa    \n",
       "  0.100  0.0002732383  0.9838458  0.9777640\n",
       "  0.100  0.0012682600  0.9850269  0.9793909\n",
       "  0.100  0.0058867416  0.9854222  0.9799276\n",
       "  0.100  0.0273238342  0.9751759  0.9658097\n",
       "  0.100  0.1268260039  0.9365629  0.9123493\n",
       "  0.325  0.0002732383  0.9834545  0.9772275\n",
       "  0.325  0.0012682600  0.9822710  0.9755978\n",
       "  0.325  0.0058867416  0.9771467  0.9685418\n",
       "  0.325  0.0273238342  0.9515344  0.9332160\n",
       "  0.325  0.1268260039  0.8282106  0.7590888\n",
       "  0.550  0.0002732383  0.9814836  0.9745208\n",
       "  0.550  0.0012682600  0.9791191  0.9712623\n",
       "  0.550  0.0058867416  0.9732051  0.9631134\n",
       "  0.550  0.0273238342  0.9365590  0.9124328\n",
       "  0.550  0.1268260039  0.7466524  0.6411450\n",
       "  0.775  0.0002732383  0.9814829  0.9745183\n",
       "  0.775  0.0012682600  0.9767561  0.9680069\n",
       "  0.775  0.0058867416  0.9688720  0.9571313\n",
       "  0.775  0.0273238342  0.9200166  0.8893438\n",
       "  0.775  0.1268260039  0.6615493  0.5140671\n",
       "  1.000  0.0002732383  0.9743908  0.9647695\n",
       "  1.000  0.0012682600  0.9755742  0.9663860\n",
       "  1.000  0.0058867416  0.9653248  0.9522299\n",
       "  1.000  0.0273238342  0.8904681  0.8480186\n",
       "  1.000  0.1268260039  0.5776165  0.3851521\n",
       "\n",
       "Accuracy was used to select the optimal model using the largest value.\n",
       "The final values used for the model were alpha = 0.1 and lambda = 0.005886742."
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "fit_glm <- train(train, y, method='glmnet', trControl = trCntrl, tuneLength = 5)\n",
    "fit_glm\n",
    "glm_accuracy <- max(fit_glm$results$Accuracy)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "549f7fdb",
   "metadata": {
    "papermill": {
     "duration": 0.022337,
     "end_time": "2023-12-10T23:41:38.928005",
     "exception": false,
     "start_time": "2023-12-10T23:41:38.905668",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.4 Classification tree"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 22,
   "id": "43feb5b3",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:41:38.977139Z",
     "iopub.status.busy": "2023-12-10T23:41:38.975143Z",
     "iopub.status.idle": "2023-12-10T23:41:42.747351Z",
     "shell.execute_reply": "2023-12-10T23:41:42.743990Z"
    },
    "papermill": {
     "duration": 3.801425,
     "end_time": "2023-12-10T23:41:42.751533",
     "exception": false,
     "start_time": "2023-12-10T23:41:38.950108",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "CART \n",
       "\n",
       "2538 samples\n",
       " 494 predictor\n",
       "   4 classes: 'anger', 'disgust', 'happy', 'sad' \n",
       "\n",
       "No pre-processing\n",
       "Resampling: Cross-Validated (5 fold) \n",
       "Summary of sample sizes: 2031, 2030, 2030, 2031, 2030 \n",
       "Resampling results:\n",
       "\n",
       "  Accuracy  Kappa   \n",
       "  0.641834  0.497939\n",
       "\n",
       "Tuning parameter 'cp' was held constant at a value of 0.02"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "fit_tree <- train(\n",
    "  x = train,\n",
    "  y = y,\n",
    "  method = \"rpart\",\n",
    "  trControl = trCntrl,\n",
    "  tuneGrid= data.frame(cp = .02)\n",
    ")\n",
    "fit_tree\n",
    "\n",
    "pred_tree <- predict(fit_tree, train, type = \"raw\")\n",
    "tree_con <- confusionMatrix(pred_tree, factor(y))\n",
    "tree_accuracy <- max(fit_tree$results$Accuracy)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "7262cb57",
   "metadata": {
    "papermill": {
     "duration": 0.021716,
     "end_time": "2023-12-10T23:41:42.795164",
     "exception": false,
     "start_time": "2023-12-10T23:41:42.773448",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.5 Support Vector Machine"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "9973bbc0",
   "metadata": {
    "papermill": {
     "duration": 0.021689,
     "end_time": "2023-12-10T23:41:42.838709",
     "exception": false,
     "start_time": "2023-12-10T23:41:42.817020",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "##### 4.2.5.1 Linear Support Vector Machine"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 23,
   "id": "fa52b6fc",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:41:42.887388Z",
     "iopub.status.busy": "2023-12-10T23:41:42.885372Z",
     "iopub.status.idle": "2023-12-10T23:42:06.023764Z",
     "shell.execute_reply": "2023-12-10T23:42:06.009455Z"
    },
    "papermill": {
     "duration": 23.170214,
     "end_time": "2023-12-10T23:42:06.031093",
     "exception": false,
     "start_time": "2023-12-10T23:41:42.860879",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Support Vector Machines with Linear Kernel \n",
       "\n",
       "2538 samples\n",
       " 494 predictor\n",
       "   4 classes: 'anger', 'disgust', 'happy', 'sad' \n",
       "\n",
       "Pre-processing: centered (494), scaled (494) \n",
       "Resampling: Cross-Validated (5 fold) \n",
       "Summary of sample sizes: 2030, 2030, 2032, 2030, 2030 \n",
       "Resampling results:\n",
       "\n",
       "  Accuracy   Kappa    \n",
       "  0.9846286  0.9788532\n",
       "\n",
       "Tuning parameter 'C' was held constant at a value of 1"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "fit_svm_lin <- train(\n",
    "  x = train,\n",
    "  y = y,\n",
    "  method = \"svmLinear\",\n",
    "  trControl = trCntrl,\n",
    "  preProcess = c(\"center\", \"scale\"),\n",
    "  tuneLength = 10\n",
    ")\n",
    "\n",
    "# Calculate predictions\n",
    "svm_rad_pred <- fit_svm_lin$pred[order(fit_svm_lin$pred$rowIndex), \"pred\"] %>% as.vector()\n",
    "# Compute confusion matrix\n",
    "svm_lin_con <- confusionMatrix.train(fit_svm_lin, \"none\")\n",
    "svm_lin_accuracy <- max(fit_svm_lin$results$Accuracy, na.rm = TRUE)\n",
    "fit_svm_lin"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "0f97dbbc",
   "metadata": {
    "papermill": {
     "duration": 0.023621,
     "end_time": "2023-12-10T23:42:06.096592",
     "exception": false,
     "start_time": "2023-12-10T23:42:06.072971",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "##### 4.2.5.2 Radial Support Vector Machine"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 24,
   "id": "05ee428a",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:42:06.147996Z",
     "iopub.status.busy": "2023-12-10T23:42:06.145945Z",
     "iopub.status.idle": "2023-12-10T23:47:02.235431Z",
     "shell.execute_reply": "2023-12-10T23:47:02.232993Z"
    },
    "papermill": {
     "duration": 296.148099,
     "end_time": "2023-12-10T23:47:02.268629",
     "exception": false,
     "start_time": "2023-12-10T23:42:06.120530",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "text/plain": [
       "Support Vector Machines with Radial Basis Function Kernel \n",
       "\n",
       "2538 samples\n",
       " 494 predictor\n",
       "   4 classes: 'anger', 'disgust', 'happy', 'sad' \n",
       "\n",
       "Pre-processing: centered (494), scaled (494) \n",
       "Resampling: Cross-Validated (5 fold) \n",
       "Summary of sample sizes: 2031, 2030, 2031, 2030, 2030 \n",
       "Resampling results across tuning parameters:\n",
       "\n",
       "  C          Accuracy   Kappa    \n",
       "       0.25  0.9286858  0.9010984\n",
       "       0.50  0.9590210  0.9433780\n",
       "       1.00  0.9775396  0.9690405\n",
       "       2.00  0.9905442  0.9869844\n",
       "       4.00  0.9940914  0.9918713\n",
       "       8.00  0.9952717  0.9934952\n",
       "      16.00  0.9952717  0.9934952\n",
       "      32.00  0.9952717  0.9934952\n",
       "      64.00  0.9952717  0.9934952\n",
       "     128.00  0.9952717  0.9934952\n",
       "     256.00  0.9952717  0.9934952\n",
       "     512.00  0.9952717  0.9934952\n",
       "    1024.00  0.9952717  0.9934952\n",
       "    2048.00  0.9952717  0.9934952\n",
       "    4096.00  0.9952717  0.9934952\n",
       "    8192.00  0.9952717  0.9934952\n",
       "   16384.00  0.9952717  0.9934952\n",
       "   32768.00  0.9952717  0.9934952\n",
       "   65536.00  0.9952717  0.9934952\n",
       "  131072.00  0.9952717  0.9934952\n",
       "\n",
       "Tuning parameter 'sigma' was held constant at a value of 0.001138497\n",
       "Accuracy was used to select the optimal model using the largest value.\n",
       "The final values used for the model were sigma = 0.001138497 and C = 8."
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "fit_svm_rad <- train(\n",
    "  x = train,\n",
    "  y = y,\n",
    "  method = \"svmRadial\",\n",
    "  trControl = trCntrl,\n",
    "  preProcess = c(\"center\", \"scale\"),\n",
    "  tuneLength = 20\n",
    ")\n",
    "\n",
    "# Calculate predictions\n",
    "svm_rad_pred <- fit_svm_rad$pred[order(fit_svm_rad$pred$rowIndex), \"pred\"] %>% as.vector()\n",
    "# Compute confusion matrix\n",
    "svm_rad_con <- confusionMatrix.train(fit_svm_rad, \"none\")\n",
    "svm_rad_accuracy <- max(fit_svm_rad$results$Accuracy)\n",
    "fit_svm_rad\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "afa37bba",
   "metadata": {
    "papermill": {
     "duration": 0.022614,
     "end_time": "2023-12-10T23:47:02.313612",
     "exception": false,
     "start_time": "2023-12-10T23:47:02.290998",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.6 Random Forest"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 25,
   "id": "a5c67746",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:47:02.363849Z",
     "iopub.status.busy": "2023-12-10T23:47:02.361901Z",
     "iopub.status.idle": "2023-12-10T23:53:34.511003Z",
     "shell.execute_reply": "2023-12-10T23:53:34.508018Z"
    },
    "papermill": {
     "duration": 392.178569,
     "end_time": "2023-12-10T23:53:34.514955",
     "exception": false,
     "start_time": "2023-12-10T23:47:02.336386",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "fit_rf <- train(\n",
    "  x = train,\n",
    "  y = y,\n",
    "  method = \"rf\",\n",
    "  trControl = trCntrl,\n",
    "  preProcess = c(\"center\", \"scale\"),\n",
    "  tuneGrid = expand.grid(mtry = 500)\n",
    ")\n",
    "\n",
    "# Calculate predictions\n",
    "rf_pred <- fit_rf$pred[order(fit_rf$pred$rowIndex), \"pred\"] %>% as.vector()\n",
    "# Compute confusion matrix\n",
    "rf_con <- confusionMatrix.train(fit_rf, \"none\")\n",
    "rf_accuracy <- max(fit_rf$results$Accuracy)\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "41066def",
   "metadata": {
    "papermill": {
     "duration": 0.029127,
     "end_time": "2023-12-10T23:53:34.579591",
     "exception": false,
     "start_time": "2023-12-10T23:53:34.550464",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "#### 4.2.7 Boosted Tree  \n",
    "We used xgboost because it is faster then the caret train"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 26,
   "id": "a51d801c",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:53:34.631908Z",
     "iopub.status.busy": "2023-12-10T23:53:34.629907Z",
     "iopub.status.idle": "2023-12-10T23:54:39.173365Z",
     "shell.execute_reply": "2023-12-10T23:54:39.170982Z"
    },
    "papermill": {
     "duration": 64.574638,
     "end_time": "2023-12-10T23:54:39.177874",
     "exception": false,
     "start_time": "2023-12-10T23:53:34.603236",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [],
   "source": [
    "cl <- parallel::makePSOCKcluster(4)\n",
    "doParallel::registerDoParallel(cl)\n",
    "\n",
    "# Convert y into numeric and make a xgboost test matrix\n",
    "y_boost <- y\n",
    "y_boost[y_boost == \"anger\"] <- 0\n",
    "y_boost[y_boost == \"happy\"] <- 1\n",
    "y_boost[y_boost == \"sad\"] <- 2\n",
    "y_boost[y_boost == \"disgust\"] <- 3\n",
    "test_matrix <- xgboost::xgb.DMatrix(as.matrix(train), label = y_boost)\n",
    "\n",
    "boost_tree <- xgboost::xgb.cv(\n",
    "  data = test_matrix,\n",
    "  num_class = 4,\n",
    "  max.depth = 4,\n",
    "  eta = 0.3,\n",
    "  nthread = 4,\n",
    "  nrounds = 50,\n",
    "  nfold = 5,\n",
    "  objective = \"multi:softprob\",\n",
    "  prediction = TRUE,\n",
    "  verbose = 0\n",
    ")\n",
    "\n",
    "\n",
    "OOF_prediction <- data.frame(boost_tree$pred) %>%\n",
    "  mutate(max_prob = max.col(., ties.method = \"last\"))\n",
    "\n",
    "y_boost <- as.numeric(y_boost) + 1\n",
    "\n",
    "# Confusion matrix\n",
    "boost_con <- confusionMatrix(factor(OOF_prediction$max_prob),\n",
    "  factor(y_boost),\n",
    "  mode = \"everything\"\n",
    ")\n",
    "\n",
    "# Compute accuracy\n",
    "boost_accuracy <- (sum(boost_con$table[c(1, 6, 11, 16)]) / sum(boost_con$table))\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "0abcf56c",
   "metadata": {
    "papermill": {
     "duration": 0.023848,
     "end_time": "2023-12-10T23:54:39.228956",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.205108",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "  <h1 id = modeleval style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    5. Model Evaluation\n",
    " </h1>\n",
    " \n",
    "In this section, we evaluate the different models previously fitted to the training data.\n",
    "Since our goal is to maximize the test data accuracy measure, we take the training data accuracy as well as the flexiblility of the learning method into account."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 27,
   "id": "ee0fd1df",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:54:39.281840Z",
     "iopub.status.busy": "2023-12-10T23:54:39.279915Z",
     "iopub.status.idle": "2023-12-10T23:54:39.756260Z",
     "shell.execute_reply": "2023-12-10T23:54:39.752962Z"
    },
    "papermill": {
     "duration": 0.508143,
     "end_time": "2023-12-10T23:54:39.760275",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.252132",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "data": {
      "image/png": "iVBORw0KGgoAAAANSUhEUgAABLAAAAHgCAIAAAA69QPIAAAABmJLR0QA/wD/AP+gvaeTAAAg\nAElEQVR4nOzddXwURxsH8GfP405CDAsEp7gUf5HiFGlpoRC8lOJuLRQpWqC00BYvUqBYcQ3F\n3TUQIUSAuOd83z/2crlc7i6XywFJ8/t+8sdmb2Z3dnb2dp/b2VmGZVkCAAAAAACA0of3oQsA\nAAAAAAAAHwYCQgAAAAAAgFIKASEAAAAAAEAphYAQAAAAAACglEJACAAAAAAAUEohIAQAAAAA\nACilEBACAAAAAACUUggIAQAAAAAASikEhAAAAAAAAKUUAkIAAAAAAIBSCgEhAAAAAABAKYWA\nEAAAAAAAoJRCQAgAAAAAAFBKISAEAAAAAAAopRAQAgAAAAAAlFIICAEAAAAAAEopBIQAAAAA\nAAClFAJCAAAAAACAUgoBIQAAAAAAQCmFgBAAAAAAAKCUQkAIAAAAAABQSiEgBAAAAAAAKKUQ\nEAIAAAAAAJRSCAgBAAAAAABKKQSEAAAAAAAApRQCQgAAAAAAgFIKASEAAAAAAEAphYAQAAAA\nAACglEJACAAAAAAAUEohIAQAAAAAACilEBACAAAAAACUUggIAQAAAAAASikEhAAAAAAAAKUU\nAkIAAAAAAIBSCgEhAAAAAABAKYWAEAAAAAAAoJRCQAgAAAAAAFBKISAEAAAAAAAopRAQAgAA\nAAAAlFIICAEAAAAAAEopBIQAAAAAAAClFAJCAAAAAACAUgoBIQAAAAAAQCmFgBAAAAAAAKCU\nQkAIAAAAAABQSiEgBAAAAAAAKKUQEAIAAAAAAJRSCAgBAAAAAABKKQSEAFBoYbtbMzrWxWaa\nmTHqZC/djLMj095pObXG+Dhwa3wpU1llgUfqenILXBiVXpTl7P/EX1sbtm5drFI2KBFWVnLh\n9vvO+Cwzs5z7tCKXZXJE6jstW8qLa+tXfNe3w8fVKpd3d7ITSuw8yvrWatpu+PjZh66GvdNV\nv3/WOpbNYcFOf//G+ztyhfRptdPMLG+ufMVl4fEl9zMV77R41q1DafIxbmmuldcVNu/7bDm6\nFGkv//p5/qA+nWpU8nd3dhAKxI7ObgE1G3TvP2rNtmNJCrXV1/ihttR8JeLIKuYQEAJAUf2y\n6IGZKf+ZdvGdlqRkUSvix/wbq/03O+nYquJ6uoVSQppwa9agdmWqNhsxef7e01eehUYmpmUp\n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\nfZ+3EBWwej2czYho280PGulPd07r16/f7JNhRCRLuTVw4MAhw2dmelZB6aoNh/YtS0TxjxIL\nox0AAAAAuXFt5UBE74480UhPfOZDRMbWHUxyXuUuOST42bNnoUmaQVr0jX1EZOrY73NZlSJ+\nau/xd2PTnZsNPe6zVWs0qFIk7NmzZ8+ePSlKLV8+n0sURFTGoXC2FvshICCEr4vhcYhIKY/6\n9H9uGSGXZdk9t79sCxH95PLi8fOJiNU+sTznk3PFk1o7E9HOKXOuvohWJ0rjX2+eNSVCrvqc\nrf2Y34joztoZJ4PeqVNU8qQzW6Z7h6fyhGXH1c9xp5pvoyDVqze+C5dhAldMPhIQ/PGaxiof\n+W+ffexpYrKiWzN7IuKbVuMnJ3yIeLj0RJDs0+ubHvPqwKE3RFQy00Y9KqVO66YCAAAA6KtU\n1z8Zhkl4tiI4Pcus0cPLHxBR2V5dcykbenhmnz59ho4/mTmRVSavWvaAiOr+1f5z4psDkwNi\n08Wlu+1fMtSarz3S4fAsr23bsHr16n/8wjQOJTzdcjdVxhU4DrI30Vr2p4Qpo/B1CcTFiW5n\nJF1NUAxQ76c3pm+tMZuvn1w44o5LJUdzfkx4eGhUnFOdrm4pJx6kJo6du6xZ/xGdsq4amovK\nA+a3Dh713/Pg5ZMH/8/Mxs5E8f5DEnGMu0/4/eDKc+o81m7DJrR/u+rkky3zRu+zdbI3VoaF\nRclULJdfbMjCudZ5T7b8ugpSPZPinRb0ezV959VdyyYdtLAvbiNKiXkfkyRjOIKOE5a7ivhE\nxDDCmYMbjtpwKXDrvJv7rEs6WikkSeGRMUqWtazcdkpdWyJiOMY2fG5sRtjoGXOKi52nTen/\nbdoOAAAABkJo1W6827pV92PHjlu7Y81YeyGX39S0gwAAIABJREFUWPmlbVO2hybzhKUX9chy\nj8yRbZ4xMqVZyfYebZ2IqPywEcKjU+IeLp65y2K6R1MRh0mPDt68cOKVxAxxmc7zG39Zbn33\nrmAiqjm+uyQ5SXs1zMRGHObvcXW7LrgcOLefp3Jx37Z1hByGVUkf+h+ZN2cbEdUZtVJsSCss\nICCEr0to1UHI8ZHK46avvLFxSl0iKtV22jLjQ3tPXXzxLjiWa+xQpvKAPn93algp6rJilueZ\n94/uhko07zbOBcM1G75ks+vxfacv3QiJiI1RmZar8VuXPoN+MfE5mClbkyGLnar5Hj198fGr\n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"
     },
     "metadata": {
      "image/png": {
       "height": 240,
       "width": 600
      }
     },
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Create data frame for the model evaluation plot\n",
    "df_plot <- data.frame(\n",
    "  model = c(\n",
    "    \"SVM Radial\",\n",
    "    \"CART\",\n",
    "    \"Boosted Tree\",\n",
    "    \"SVM Linear\",\n",
    "    \"Multinomial Lasso\",\n",
    "    \"Random Forest\",\n",
    "    \"Multinomial logistic regression\",\n",
    "    \"QDA\"\n",
    "  ),\n",
    "  accuracy = c(\n",
    "    svm_rad_accuracy,\n",
    "    tree_accuracy,\n",
    "    boost_accuracy,\n",
    "    svm_lin_accuracy,\n",
    "    lasso_accuracy,\n",
    "    rf_accuracy,\n",
    "    glm_accuracy,\n",
    "    qda_accuracy\n",
    "  )\n",
    ")\n",
    "\n",
    "# set plot width\n",
    "options(repr.plot.width = 10)\n",
    "\n",
    "# Plot model evaluation\n",
    "df_plot %>%\n",
    "  ggplot(aes(x = fct_reorder(model, accuracy), y = accuracy, fill = model)) +\n",
    "  geom_bar(stat = \"identity\", ) +\n",
    "  geom_text(aes(label = round(accuracy, 3)),\n",
    "    vjust = 0.5,\n",
    "    hjust = 1.1,\n",
    "    size = 5\n",
    "  ) +\n",
    "  scale_y_continuous(expand = c(0, 0), limits = c(0, 1)) +\n",
    "  scale_fill_manual(values = c(rep(\"grey80\", times = nrow(df_plot) - 1), \"tomato\")) +\n",
    "  theme_classic() +\n",
    "  theme(\n",
    "    text = element_text(size = 17),\n",
    "    axis.text.x = element_text(),\n",
    "    legend.position = \"none\",\n",
    "    aspect.ratio = 1 / 3\n",
    "  ) +\n",
    "  coord_flip() +\n",
    "  xlab(\"Model\") +\n",
    "  ylab(\"Classification Accuracy\") +\n",
    "  ggtitle(\"Model Accuracy with Correlation Variable Selection\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "19a9d9e2",
   "metadata": {
    "papermill": {
     "duration": 0.025621,
     "end_time": "2023-12-10T23:54:39.811260",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.785639",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "### Conclusion on Model Choice\n",
    "We fitted different models ranging from very flexible SVM models to a quite rigid lasso regression model in order to evaluate how complex our model needs to be for a maximized test data accuracy. \n",
    "\n",
    "For the two SVM models, we found very high training data accuracy (>.95), but a substantive drop in test data accuracy (\\~.84). Given these results, we concluded to be overfitting on the training data using a model that is too flexible. However, on the other side of the flexibility axis, our lasso regression model with 91 non-zero predictor coefficients yielded suspiciously high training data accuracy (>.95) as well and performed even worse on the test data (\\~.81). With no more test submissions left and assuming there is no conceptual error in the code, we concluded that overfitting might only have a smaller impact \n",
    "and that an issue could be that the training data might not be representative of the test data.\n",
    "Another issue could be, that the CK+ dataset is a relatively small dataset, and it might contain a lot of variation in terms of the quality of the images. \n",
    "\n",
    "If we had more test submissions left, it would be interesting to fit a model that performs similarly on the training data but represents a middleground in flexibility between the rigid lasso and the complex SVM.\n",
    "\n",
    "Finally, we chose the **radial SVM as our preferred model for the test data predicitions** because it yielded both the best training data accuracy and the best test data accuracy - well aware of the potential issues discussed above."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "db0098d0",
   "metadata": {
    "papermill": {
     "duration": 0.025622,
     "end_time": "2023-12-10T23:54:39.862032",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.836410",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    " <h1 id = submission style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    6. Prediction on Test Data, Submisson & Conclusion\n",
    " </h1>\n",
    " \n",
    " Finally, we predict the emotional expression of the 1080 test data images using our SVM model of choice.\n",
    " We format predictions to comply to the submission format and draw our final conclusions."
   ]
  },
  {
   "cell_type": "markdown",
   "id": "ecc25688",
   "metadata": {
    "papermill": {
     "duration": 0.024374,
     "end_time": "2023-12-10T23:54:39.912160",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.887786",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.1 Prediction on Test Data"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 28,
   "id": "6d7912ca",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:54:39.965234Z",
     "iopub.status.busy": "2023-12-10T23:54:39.963153Z",
     "iopub.status.idle": "2023-12-10T23:54:41.632838Z",
     "shell.execute_reply": "2023-12-10T23:54:41.628046Z"
    },
    "papermill": {
     "duration": 1.703866,
     "end_time": "2023-12-10T23:54:41.640205",
     "exception": false,
     "start_time": "2023-12-10T23:54:39.936339",
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
       "<ol class=list-inline><li>anger</li><li>anger</li><li>anger</li><li>anger</li><li>anger</li><li>anger</li></ol>\n",
       "\n",
       "<details>\n",
       "\t<summary style=display:list-item;cursor:pointer>\n",
       "\t\t<strong>Levels</strong>:\n",
       "\t</summary>\n",
       "\t<style>\n",
       "\t.list-inline {list-style: none; margin:0; padding: 0}\n",
       "\t.list-inline>li {display: inline-block}\n",
       "\t.list-inline>li:not(:last-child)::after {content: \"\\00b7\"; padding: 0 .5ex}\n",
       "\t</style>\n",
       "\t<ol class=list-inline><li>'anger'</li><li>'disgust'</li><li>'happy'</li><li>'sad'</li></ol>\n",
       "</details>"
      ],
      "text/latex": [
       "\\begin{enumerate*}\n",
       "\\item anger\n",
       "\\item anger\n",
       "\\item anger\n",
       "\\item anger\n",
       "\\item anger\n",
       "\\item anger\n",
       "\\end{enumerate*}\n",
       "\n",
       "\\emph{Levels}: \\begin{enumerate*}\n",
       "\\item 'anger'\n",
       "\\item 'disgust'\n",
       "\\item 'happy'\n",
       "\\item 'sad'\n",
       "\\end{enumerate*}\n"
      ],
      "text/markdown": [
       "1. anger\n",
       "2. anger\n",
       "3. anger\n",
       "4. anger\n",
       "5. anger\n",
       "6. anger\n",
       "\n",
       "\n",
       "\n",
       "**Levels**: 1. 'anger'\n",
       "2. 'disgust'\n",
       "3. 'happy'\n",
       "4. 'sad'\n",
       "\n",
       "\n"
      ],
      "text/plain": [
       "[1] anger anger anger anger anger anger\n",
       "Levels: anger disgust happy sad"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "## Make predictions for SVM \n",
    "pred_test_svm <- predict(fit_svm_rad, test, decision.values = TRUE)\n",
    "head(pred_test_svm)"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "87a482bd",
   "metadata": {
    "papermill": {
     "duration": 0.043061,
     "end_time": "2023-12-10T23:54:41.733717",
     "exception": false,
     "start_time": "2023-12-10T23:54:41.690656",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.2 Prepare Submission File"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 29,
   "id": "72e411c3",
   "metadata": {
    "execution": {
     "iopub.execute_input": "2023-12-10T23:54:41.787480Z",
     "iopub.status.busy": "2023-12-10T23:54:41.785543Z",
     "iopub.status.idle": "2023-12-10T23:54:41.980218Z",
     "shell.execute_reply": "2023-12-10T23:54:41.977898Z"
    },
    "papermill": {
     "duration": 0.224917,
     "end_time": "2023-12-10T23:54:41.983377",
     "exception": false,
     "start_time": "2023-12-10T23:54:41.758460",
     "status": "completed"
    },
    "tags": []
   },
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "file,category\n",
      "S010_004_00000017a.png,anger\n",
      "S010_004_00000017b.png,anger\n",
      "S010_004_00000017c.png,anger\n",
      "S010_004_00000017d.png,anger\n",
      "S010_004_00000017e.png,anger\n",
      "S010_004_00000017f.png,anger\n",
      "S011_002_00000022a.png,sad\n",
      "S011_002_00000022b.png,sad\n",
      "S011_002_00000022c.png,sad\n",
      "S011_002_00000022d.png,sad\n",
      "S011_002_00000022e.png,sad\n",
      "S011_002_00000022f.png,sad\n",
      "S011_005_00000018a.png,disgust\n",
      "S011_005_00000018b.png,disgust\n",
      "S011_005_00000018c.png,disgust\n",
      "S011_005_00000018d.png,disgust\n",
      "S011_005_00000018e.png,disgust\n",
      "S011_005_00000018f.png,disgust\n",
      "S011_006_00000013a.png,happy\n"
     ]
    }
   ],
   "source": [
    "## Choose prediction for submission\n",
    "final_pred <- pred_test_svm\n",
    "\n",
    "## Write to file\n",
    "tibble(\n",
    "  file = rownames(X_test),\n",
    "  category = final_pred\n",
    ") %>%\n",
    "  write_csv(path = \"submission.csv\")\n",
    "\n",
    "## Check result\n",
    "cat(readLines(\"submission.csv\", n = 20), sep = \"\\n\")\n"
   ]
  },
  {
   "cell_type": "markdown",
   "id": "c40aef8f",
   "metadata": {
    "papermill": {
     "duration": 0.025983,
     "end_time": "2023-12-10T23:54:42.041609",
     "exception": false,
     "start_time": "2023-12-10T23:54:42.015626",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "## 6.3 Conclusion\n",
    "In this competition our task was to build an algorithm that is able to recognize emotions from photographs depicting facial expressions. The given CK+ data set contains photos of faces that express one of the emotions anger, disgust, happiness, and sadness. \n",
    "\n",
    "We extracted features based on the raw pixel approach, Frey & Slate features (FSF), edge-based histogram features, Histogram of Oriented Gradients (HoG) features, and Power Spectral Density (PSD) features.\n",
    "Using a training data set of 2538 images we fitting different models ranging from very flexible SVM models to a quite rigid lasso regression model in order to evaluate how complex our model needs to be for a maximized test data accuracy. \n",
    "\n",
    "As discussed in section 5, we chose the radial Support Vector Machine model for our test set predictions. Although we saw an indication of overfitting in the drop from the training data accuracy (>.98) to the test data accuracy (\\~.85), this model still performed better than other less flexible models. \n",
    "\n",
    "On the test data of 1080 images, our model predicted the correct emotional expression in around `84.7%`.\n",
    "We cannot draw conclusions about the accuracy measures concerning each specific emotions. However,  comparing this general accuracy measure to the Bayes' error bound (62.3% - 79.6%, depending on the emotion, see [above](#intro)), our model performs substantially better. "
   ]
  },
  {
   "cell_type": "markdown",
   "id": "4076b549",
   "metadata": {
    "papermill": {
     "duration": 0.02743,
     "end_time": "2023-12-10T23:54:42.094477",
     "exception": false,
     "start_time": "2023-12-10T23:54:42.067047",
     "status": "completed"
    },
    "tags": []
   },
   "source": [
    "<h1 id = div_labor_refs style = 'font-size:26px; color: #202680; border-left: 6px solid #202680; padding: 10px;'>\n",
    "    7. Division of Labor & References\n",
    "</h1>\n",
    " \n",
    "### 7.1 Division of Labor \n",
    " * **L**: Most of feature extraction, model fitting, model evaluation\n",
    " * **T**: Model fitting, edge-based histogram features, model evaluation, notebook formatting\n",
    " * **L**: Notebook formatting, texts, bits of feature extraction, lasso regression, model evaluation,\n",
    "\n",
    "### 7.2 References\n",
    "\n",
    "* Carcagnì, P., Del Coco, M., Leo, M., & Distante, C. (2015). Facial expression recognition and histograms of oriented gradients: a comprehensive study. SpringerPlus, 4(1), 1-25.\n",
    "* Lucey, P., Cohn, J. F., Kanade, T., Saragih, J., Ambadar, Z., & Matthews, I. (2010, June). The extended cohn-kanade dataset (ck+): A complete dataset for action unit and emotion-specified expression. In 2010 ieee computer society conference on computer vision and pattern recognition-workshops (pp. 94-101). IEEE.\n",
    "* Mollahosseini, A., Abdollahi, H., Sweeny, T. D., Cole, R., & Mahoor, M. H. (2018). Role of embodiment and presence in human perception of robots’ facial cues. International Journal of Human-Computer Studies, 116, 25-39.\n",
    " "
   ]
  }
 ],
 "metadata": {
  "kaggle": {
   "accelerator": "none",
   "dataSources": [
    {
     "databundleVersionId": 6819009,
     "sourceId": 62738,
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
   "duration": 1545.087347,
   "end_time": "2023-12-10T23:54:42.376680",
   "environment_variables": {},
   "exception": null,
   "input_path": "__notebook__.ipynb",
   "output_path": "__notebook__.ipynb",
   "parameters": {},
   "start_time": "2023-12-10T23:28:57.289333",
   "version": "2.4.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
