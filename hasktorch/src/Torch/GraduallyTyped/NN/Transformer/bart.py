import argparse
import pprint
from typing import Any
import torch
from transformers import AutoTokenizer, BartForConditionalGeneration

def pretty_convert(x: Any) -> Any:
    if isinstance(x, torch.Tensor):
        return x.tolist()
    else:
        return x

def pretty_print(x: dict) -> None:
    y = {k: pretty_convert(v) for k, v in x.items()}
    pp = pprint.PrettyPrinter(indent=4, compact=True, width=120)
    pp.pprint(y)


def main(args=None) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="facebook/bart-base")
    parser.add_argument("--input", required=True)
    args = parser.parse_args()
    pretty_print(args.__dict__)

    tokenizer = AutoTokenizer.from_pretrained(args.model)

    tokenized_inputs = tokenizer([args.input], padding="longest", return_tensors="pt")
    pretty_print(tokenized_inputs)
    back_decoded = tokenizer.batch_decode(tokenized_inputs['input_ids'], skip_special_tokens=False)
    print({'back_decoded': back_decoded})

    model = BartForConditionalGeneration.from_pretrained(args.model, torchscript=False)
    model.eval()

    generated_ids = model.generate(
        input_ids=tokenized_inputs.input_ids,
        attention_mask=tokenized_inputs.attention_mask,
        num_beams=1,
        max_length=512,
        do_sample=False,
        repetition_penalty=1,
        no_repeat_ngram_size=0,
    )

    decoded = tokenizer.batch_decode(generated_ids, skip_special_tokens=False)
    pretty_print({"generated_ids": generated_ids, "decoded": decoded})


if __name__ == "__main__":
    main()
