# read data
df = read_csv(file.path(data_path, fname_raw), 
              na = c("", "NA", "NO VALUE", "Unknown", "Unknown \r\r\n"))
names(df)[1] = "pid"
names(df) = gsub(" ", "_", names(df))
# str(df)

# remove potentially erroneous data 
df = df %>% filter(
        # data before 2012 are manually collected from paper records, drop them
        Admission_Date > as.Date("2012-01-01"),
        Episode_of_Care_Type_Desc == "1 - Acute Care"
        ) %>% mutate(Episode_of_Care_Type_Desc = NULL)

# dedupe
dupes_logical = duplicated(df)
if (sum(dupes_logical) > 0) df = df[!dupes_logical,]

# # dedupe based on all vars but the ID vars, can take some time
# dupes_logical = duplicated(df %>% select(-pid, -Stay_Number))
# if (sum(dupes_logical) > 0) df = df[!dupes_logical,]

# # same patient can have multiple rows as seen by same Stay_Number, LOS and yvar
# head(sort(table(df$Stay_Number), decreasing = T))
# tmp = df %>% filter(Stay_Number == 80962188)
# View(tmp)
# length(unique(tmp$LOS)) == 1
# length(unique(tmp$unplanned_readmit_28_Days)) == 1

# # for those duplicated patients, remove all but the first row
# dupes_logical = duplicated(df %>% select(Stay_Number, LOS, unplanned_readmit_28_Days))
# dupes_logical2 = duplicated(df %>% select(Stay_Number, LOS))
# dupes_logical3 = duplicated(df %>% select(Stay_Number))
# stopifnot(sum(dupes_logical) == sum(dupes_logical2))
# stopifnot(sum(dupes_logical) == sum(dupes_logical3))
# if (sum(dupes_logical) > 0) df = df[!dupes_logical,]
# stopifnot(length(unique(df$Stay_Number)) == nrow(df))

