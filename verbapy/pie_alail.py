import json
from verbatoks import Verbatoks
from pie_extended.cli.utils import get_tagger, get_model, download
from pie_extended.models.grc.imports import get_iterator_and_processor


corpus = [
    """
<div type="textpart" subtype="book" n="1">BOOK1

                <head>ΓΑΛΗΝΟΥ ΠΕΡΙ ΤΗΣ ΕΞ ΕΝΥΠΝΙΩΝ <lb/>ΔΙΑΓΝΩΣΕΩΣ.</head>
                <p>Τὸ ἐνύπνιον δὲ ἡμῖν ἐνδείκνυται διάθεσιν τοῦ σώματος. <lb/>πυρκαϊὰν μέν τις ὁρῶν
                    ὄναρ ὑπὸ τῆς ξανθῆς <lb/>ἐνοχλεῖται χολῆς· εἰ δὲ καπνὸν, ἢ ἀχλὺν, ἢ βαθὺ σκότος,
                    <lb/>ὑπὸ τῆς μελαίνης χολῆς· ὄμβρος δὲ ψυχρὰν ὑγρότητα <lb/>πλεονάζειν
                    ἐνδείκνυται· χιὼν δὲ καὶ κρύσταλλος καὶ χάλαζα <lb/>
    """
    , """
    <div type="textpart" subtype="book" n="3">BOOK3
                    <div type="textpart" subtype="chapter" n="1">
                        <head>ΓΑΛΗΝΟΥ ΠΕΡΙ ΑΙΤΙΩΝ ΣΥΜΠΤΩΜΑΤΩΝ <lb/>ΒΙΒΛΙΟΝ ΤΡΙΤΟΝ.</head>
                        <p>Ὅτι δὲ ὅσα κατὰ τὰς φυσικὰς ἐνεργείας <lb/>τε καὶ δυνάμεις ἀποτελεῖται
                            συμπτώματα τὴν αὐτὴν μὲν <lb/>ἔχει μέθοδον τῆς εὑρέσεως, ἥνπερ καὶ τὰ
                            ταῖς ψυχικαῖς <lb/>ἐνεργείαις ἐπιγινόμενα, κάλλιον μὲν ἴσως ἐστὶ κᾀν
                            τοῖς τούτων <lb/>εἴδεσι γυμνάσασθαι κατὰ μέρος, ὥσπερ κᾀν τοῖς τῶν
                            <lb/>ψυχικῶν ἐγυμνασάμεθα. τὸ μὲν δὴ κεφάλαιόν ἐστι τῆς <lb/>εὑρέσεως
                            ἁπάντων τῶν αἰτίων ὅσα λυμαίνεται ταῖς δυνάμεσιν <lb/>ἡ γνῶσις τοῦ
                            τρόπου καθ’ ὃν ἐνήργουν ὑγιαίνουσαι. <pb n="206"/> εἰ μὲν γὰρ τῷ τρίβειν
                            ἡ γαστὴρ ἔπεττε τὰ σιτία, περὶ τὸ τρίβειν <lb/>ἐμποδισθεῖσα τὰ τῆς
                            πέψεως ἀποτελέσει συμπτώματα· <lb/>μηδ’ ὅλως μὲν τρίψασα, τὸ μηδ’ ὅλως
                            πέψαι· μοχθηρῶς δὲ <lb/>τρίψασα, τὸ μοχθηρῶς πέψαι. κατὰ δὲ τὸν αὐτὸν
                            τρόπον, <lb/>εἰ τῷ σήπειν ἔπεττεν, οὐ πέψει τῷ μὴ σῆψαι. εἰ δ’, ὡς
                            <lb/>ἡμεῖς ἀπεδείξαμεν, αὐτὴ μὲν ἡ πέψις ἀλλοίωσίς ἐστι κατὰ <lb/>
                            <milestone unit="ed2page" n="238"/>ποιότητα, γίγνεται δὲ ὑπὸ τῆς γαστρὸς
                            ὁμοιούσης <lb/>ἑαυτῇ τὰ σιτία, παντί που δῆλον, ὡς ἡ περὶ τὴν ἀλλοίωσιν
                            <lb/>ἀποτυχία σύμπτωμα γενήσεται πέψεως. εἰ μὲν δὴ μηδ’ ὅλως
                            <lb/>ἀλλοιωθείη, καλεῖται μὲν ἀπεψία τὸ σύμπτωμα, καθάπερ <lb/>ἀκινησία
                            τε καὶ ἀναισθησία περὶ τὰ τῆς ψυχῆς ἔργα, σημαινουσῶν <lb/>ἀπώλειάν τε
                            καὶ στέρησιν τῆς ἐνεργείας τοῦ πρώτου <lb/>μορίου τῆς ψυχῆς.
    """
]
i = 0

# using pie-extended to generate a list of lemma and words
model_name = "grc"
tagger = get_tagger(model_name, batch_size=256, device="cpu", model_path=None)
# 5 s.
iterator, processor = get_iterator_and_processor()


for text in corpus:
    toks, starts, ends = Verbatoks.listing(text)
    vert = "\n".join(toks)
    print("=====================")
    print(vert)
    print("=====================")
    i = 0
    count = len(toks)
    for form in tagger.tag_str(
        vert, 
        iterator=iterator, 
        processor=processor, 
        no_tokenizer=True
    ):
        # last 
        if (i > count):
            break
        print(
            str(i)
            +"\t"+str(starts[i])
            +"\t"+str(ends[i])
            +"\t"+str(toks[i])
            +"\t"+json.dumps(form, ensure_ascii=False)
        )
        i = i + 1

