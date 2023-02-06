import sys
import pandas as pd

robot_export = sys.argv[1]
report = sys.argv[2]

re_df = pd.read_table(robot_export, dtype="string")
re_df = re_df.rename(
    columns={
        "ID": "id",
        "LABEL": "label",
        "oboInOwl:hasDbXref": "xref",
        "Equivalent Class [ID]": "eqclass",
        "SubClass Of [ID]": "subclass",
    }
).set_index('id')

imports = re_df.filter(regex='^(?!DOID:)', axis=0).reset_index()
imports = imports[['id', 'label']]

doid = re_df.set_index('id').filter(regex="DOID", axis=0)
doid = doid.reset_index().fillna('')

xref = (
    doid.xref.str.extractall('(?P<icdo>ICDO:[0-9/]+)')
    .groupby(level=0)['icdo'].apply(list)
)

# need to limit this to RO:0004026, use some type of lookahead for last ) to get entire statement?
uberon = (
    (doid.eqclass + doid.subclass).str
    .extractall('(?P<uberon_id>UBERON:[0-9]+)')
    .groupby(level=0)['uberon_id'].apply(list)
)
.explode()
    .to_frame('uberon_id')

    .reset_index()
    .merge(
		imports.rename(columns={'id': 'uberon_id', 'label': 'anatomy'}),
		how = 'left',
		left_on='uberon_id',
		right_on='uberon_id'
	)
)

blah = uberon

x = (doid.xref.str.extractall('(?P<icdo>ICDO:[0-9/]+)')
    .groupby(level=0)['icdo'].apply(list))

doid.drop(columns=['eqclass', 'subclass']).join(uberon_id)

pd.concat(eqclass, subclass)

doid = doid.merge(
    ,
    subclass = doid.subclass.str.extractall('(?P<uberon>UBERON:[0-9]+)')
)



doid2 = doid
doid2.join(eqclass)
doid['eqclass'].str.
df_labels.columns = ["term", "annotation"]
df_labels = df_labels.astype(str)

df_synonyms = pd.read_csv(synonyms)
df_synonyms.columns = ["term", "annotation"]
df_synonyms = df_synonyms.astype(str)

df_dict = pd.read_csv(dictionary)
df_dict.columns = ["be", "ae"]

lang_dict = {}
for idx, row in df_dict.iterrows():
    american = str(row["ae"])
    british = str(row["be"])
    lang_dict[american] = british


def translate_be(df, lang_dict):
    be = []
    for label in df["annotation"]:
        new_label = []
        for lsub in label.split(" "):
            if lsub in lang_dict:
                new_label.append(lang_dict[lsub])
            else:
                new_label.append(lsub)
        be.append(" ".join(new_label))
    return be


# Add the British synonyms to the DataFrame
df_labels["be"] = translate_be(df_labels, lang_dict)
df_synonyms["be"] = translate_be(df_synonyms, lang_dict)

# Drop any rows that don't have British synonyms
df_labels.dropna(inplace=True)
df_synonyms.dropna(inplace=True)

# Remove any rows in which the synonym already exists as synonym or label
all_existing = df_labels["annotation"].tolist()
all_existing.extend(df_synonyms["annotation"].tolist())
df_labels = df_labels[~df_labels["be"].isin(all_existing)]
df_synonyms = df_synonyms[~df_synonyms["be"].isin(all_existing)]

# Merge labels and synonyms
df_labels = df_labels.rename({"annotation": "label"}, axis=1)
df_synonyms = df_synonyms.rename({"annotation": "synonym"}, axis=1)
df_be_syns = df_labels.merge(df_synonyms, on=["term"], how="inner")

# Aggregate rows for each term ID
mini_df = df_be_syns[["term", "be_y"]]
mini_df_2 = df_be_syns[["term", "synonym"]]
mini_df = (
    mini_df.groupby("term")["be_y"]
    .apply(lambda x: "|".join(list(x)))
    .reset_index(name="new synonyms")
)
mini_df_2 = (
    mini_df_2.groupby("term")["synonym"]
    .apply(lambda x: "|".join(list(x)))
    .reset_index(name="synonyms")
)
mini_df = mini_df.merge(mini_df_2, on=["term"])
df_be_syns = df_be_syns.drop(["synonym", "be_y"], axis=1).drop_duplicates()
df_be_syns = df_be_syns.merge(mini_df, on=["term"])
df_be_syns["new synonyms 2"] = df_be_syns["be_x"] + "|" + df_be_syns["new synonyms"]
df_be_syns.drop(["new synonyms", "be_x"], axis=1, inplace=True)

# Add ROBOT template string and sort by ID
df_be_syns.loc[-1] = ["ID", "", "", "AL has_exact_synonym@en SPLIT=|"]
df_be_syns.index = df_be_syns.index + 1
df_be_syns.sort_index(inplace=True)
df_be_syns.columns = ["ID", "Label", "Synonyms", "British Synonyms"]
df_be_syns["ID"] = df_be_syns["ID"].apply(
    lambda x: x.replace("http://purl.obolibrary.org/obo/", "").replace("_", ":")
)

# Save template
if df_be_syns.empty:
    print("No new synonyms to add!")
    sys.exit(1)
df_be_syns.to_csv(template, index=False)
