from collections import defaultdict
from nltk.util import ngrams
from typing import Tuple
import pickle


class NgramModel:
    def __init__(self, max_prior_token_length: int = None, max_top_n: int = 10) -> None:
        """
        Initialize n-gram counter from tokenized text and count number of n-grams in text
        :param file_name: path of tokenized text. Each line is a sentence with tokens separated by comma.
        """
        self.max_prior_token_length = max_prior_token_length
        self.max_ngram_length = (
            self.max_prior_token_length + 1
        )  # Compute ngrams of this length from corpus
        self.counts = defaultdict(int)
        self.token_count = None
        self.max_top_n = max_top_n
        self.vocab_size = None
        self.uniform_prob = None
        self.probs = {}
        self.lookup_tables = {}

    def count(self, corpus):
        """
        Count all ngrams
        """
        self.token_count = len(corpus)

        for ngram_length in range(1, self.max_ngram_length + 1):
            ngram_list = list(ngrams(corpus, ngram_length))
            for ngram in ngram_list:
                self.counts[ngram] += 1

        self.vocab_size = len(
            list(ngram for ngram in self.counts.keys() if len(ngram) == 1)
        )
        self.uniform_prob = 1 / (self.vocab_size)

    def calculate_unigram_prob(self, unigram: Tuple[str]) -> None:
        """
        Calculate conditional probability for a unigram
        :param unigram: length-1 tuple containing the unigram
        """

        prob_nom = self.counts[unigram]
        prob_denom = self.token_count
        self.probs[unigram] = prob_nom / prob_denom

    def calculate_multigram_prob(self, ngram: Tuple[str]) -> None:
        """
        Calculate conditional probability for higher n-gram (multigram)
        :param ngram: tuple containing words of the n-gram
        """
        prevgram = ngram[:-1]
        prob_nom = self.counts[ngram]
        prob_denom = self.counts[prevgram]
        self.probs[ngram] = prob_nom / prob_denom

    def train(self) -> None:
        """
        For each n-gram, calculate its conditional probability in the training
        text
        """
        for ngram in self.counts:
            if len(ngram) == 1:
                self.calculate_unigram_prob(ngram)
            else:
                self.calculate_multigram_prob(ngram)
        # For each ngram_length, construct the lookup dict of the top_n next
        # tokens where top_n is max_top_n
        for ngram_length in range(1, self.max_ngram_length + 1):
            self.lookup_tables[ngram_length] = self.lookup_dict_top_n(
                ngram_length, self.max_top_n
            )

    def dd():
        return defaultdict(dict)

    def lookup_dict_top_n(self, ngram_length, top_n):
        """
        Get the probability lookup table for ngram_length and store in a
        dictionary for easy lookup.
        """
        # get probs for ngram_length of interest, sort
        subset_probs = {
            k: self.probs[k] for k in list(self.probs.keys()) if len(k) == ngram_length
        }
        sorted_probs = dict(
            sorted(subset_probs.items(), reverse=True, key=lambda item: item[1])
        )

        # convert tuple to nested dict
        d = defaultdict(defaultdict(dict).copy)  # lambda: defaultdict(dict))
        for k, v in sorted_probs.items():
            d[k[0:-1]][k[-1]] = v

        # only keep key/value combo associated with n highest probs
        filtered_d = defaultdict(
            defaultdict(dict).copy
        )  # self.dd())#lambda: defaultdict(dict))
        for k, v in d.items():
            filtered_d[k] = list(v.keys())[0:top_n]

        return filtered_d

    def predict(self, prior_tokens, top_n, verbose=False):
        """
        Predict the top_n next tokens given the prior tokens

        Args:
        prior_tokens (Tuple): A tuple of tokenized words ()
        """
        prior_ngram_length = len(prior_tokens)

        if prior_ngram_length < self.max_ngram_length:
            if prior_ngram_length == 0:
                subset_probs = {
                    key: value for key, value in self.probs.items() if len(key) == 1
                }
                tokens = list(
                    dict(
                        sorted(
                            subset_probs.items(), reverse=True, key=lambda item: item[1]
                        )
                    ).keys()
                )[0:top_n]
                tokens_topn = list(
                    map(lambda x: x[0], tokens[0 : min(top_n, len(tokens))])
                )
                return tokens_topn
            else:
                if self.lookup_tables[prior_ngram_length + 1].get(prior_tokens):
                    topn_preds = self.lookup_tables[prior_ngram_length + 1][
                        prior_tokens
                    ]
                    return topn_preds[0:top_n]
                else:
                    # Recursively trim tokens
                    prior_tokens = prior_tokens[1:]
                    if len(prior_tokens) > 0:
                        return self.predict(prior_tokens, top_n)
                    else:
                        return []
        else:
            print(
                "Context too long. Should be less than max ngram length used to build and train model."
            )
            return []

    def save(self, save_path: str):
        # Build dict object to serialize
        model_dict = {
            "max_prior_token_length": self.max_prior_token_length,
            "max_ngram_length": self.max_ngram_length,
            "probs": self.probs,
            "lookup_tables": self.lookup_tables,
            "vocab_size": self.vocab_size,
            "max_top_n": self.max_top_n,
        }
        with open(save_path, "wb") as f:
            pickle.dump(model_dict, f)

    def load(self, model_dict: str):
        with open(model_dict, "rb") as f:
            model_dict = pickle.load(f)

        self.max_prior_token_length = model_dict["max_prior_token_length"]
        self.max_ngram_length = model_dict["max_ngram_length"]
        self.probs = model_dict["probs"]
        self.lookup_tables = model_dict["lookup_tables"]
        self.vocab_size = model_dict["vocab_size"]
        self.max_top_n = model_dict["max_top_n"]
