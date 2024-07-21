create policy "Users can only modify, view their own seasons"
    on "public"."seasons"
    as permissive
    for all
    to authenticated
    using (auth.uid() = owner)
    with check (auth.uid() = owner);
