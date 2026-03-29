// Copyright © 2020 Metabolist. All rights reserved.

import Mastodon
import SwiftUI
import ViewModels

struct ListsView: View {
    @StateObject var viewModel: ListsViewModel
    @EnvironmentObject var rootViewModel: RootViewModel
    @State private var newListTitle = ""

    @ViewBuilder
    private var editButton: some View {
        if viewModel.identityContext.isGoToSocial {
            EmptyView()
        } else {
            EditButton()
        }
    }

    var body: some View {
        if viewModel.identityContext.isGoToSocial {
            unsupportedView
        } else {
            listsForm
        }
    }

    private var unsupportedView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image("sad-sloth")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160)
            Text("lists.gotosocial-unsupported")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(Text("secondary-navigation.lists"))
    }

    private var listsForm: some View {
        Form {
                Section {
                    TextField("lists.new-list-title", text: $newListTitle)
                        .accessibilityIdentifier("lists.new-list-title")
                        .disabled(viewModel.creatingList)
                    if viewModel.creatingList {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Button {
                            viewModel.createList(title: newListTitle)
                        } label: {
                            Label("add", systemImage: "plus.circle")
                        }
                        .accessibilityIdentifier("lists.add")
                        .disabled(newListTitle.isEmpty)
                    }
                }
                Section {
                    ForEach(viewModel.lists) { list in
                        Button {
                            rootViewModel.navigationViewModel?.navigate(timeline: .list(list))
                        } label: {
                            Text(list.title)
                                .foregroundColor(.primary)
                        }
                        .accessibilityIdentifier("lists.item.\(list.title)")
                    }
                    .onDelete {
                        guard let index = $0.first else { return }

                        viewModel.delete(list: viewModel.lists[index])
                    }
                }
            }
        .navigationTitle(Text("secondary-navigation.lists"))
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                editButton
            }
        }
        .alertItem($viewModel.alertItem)
        .onAppear {
            if !viewModel.identityContext.isGoToSocial {
                viewModel.refreshLists()
            }
        }
        .onReceive(viewModel.$creatingList) {
            if !$0 {
                newListTitle = ""
            }
        }
    }
}

#if DEBUG
import PreviewViewModels

struct ListsView_Previews: PreviewProvider {
    static var previews: some View {
        ListsView(viewModel: .init(identityContext: .preview))
            .environmentObject(NavigationViewModel(identityContext: .preview, environment: .preview))
    }
}
#endif
