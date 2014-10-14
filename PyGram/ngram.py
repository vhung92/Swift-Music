import operator


class NGram:

    def __init__(self, n):
        """
        Initializes a new NGram object with
        :param n: number of grams (i.e. bi-gram, tri-gram, etc.)
        :return: an NGram oject
        """
        self.total = 0  # total number of added grams
        self.n = n  # n of n-gram (i.e. bi-gram)
        self.grams = {}  # dictionary in dictionary: n-gram -> next token -> frequency

    def add(self, sequence):
        """
        Trains (if you will) NGram model with new sequence of tokens (whatever those may be)
        :param sequence: list of tokens
        :return: void
        """
        for i in range(len(sequence) - self.n):
            self.total += 1  # increment for each new gram added to the model
            new_gram = tuple(sequence[i:i + self.n])
            temp_next = sequence[i + self.n]
            if new_gram in self.grams:
                if temp_next in self.grams[new_gram]:
                    self.grams[new_gram][temp_next] += 1  # only add frequency counter
                else:
                    self.grams[new_gram][temp_next] = 1  # initialize frequency
            else:
                self.grams[new_gram] = {temp_next: 1}

    def generate(self, start, max_iterations):
        """
        Generates new tokens based on the (trained) model
        :param start: start n-gram
        :param max_iterations: maximum number of added tokens
        :return: list of newly generated tokens
        """
        current = start
        output = list(current)
        for i in range(max_iterations):
            if current in self.grams:
                possible_next = self.grams[current]
                temp_next = max(possible_next.iteritems(), key=operator.itemgetter(1))[0]
                output.append(temp_next)
                current = tuple(output[-self.n:])
            else:
                break
        return output

    def probability(self, gram):
        """
        Calculates the probability of a specified gram in the model
        :param gram: the gram we want to know the probability for
        :return: probability of gram in model
        """
        if gram in self.grams:
            return len(self.grams[gram]) * 1.0 / self.total
        else:
            return 0.0


if __name__ == '__main__':

    n_gram = NGram(2)  # new 2-gram model

    text = "This is some random text to be used for the for the for the model"
    n_gram.add(text.split())

    print str(n_gram.n) + "-grams: " + str(n_gram.grams)
    print "Total #: " + str(n_gram.total)
    a = ("This", "is")
    print "Probability of " + str(a) + ": " + str(n_gram.probability(a))
    b = ("some", "random")
    print "Generated from " + str(b) + ": " + str(n_gram.generate(b, 10))
