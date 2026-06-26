<?php

namespace App\Filament\Resources;

use App\Filament\Resources\HouseholdResource\Pages;
use App\Models\Household;
use Filament\Actions\ViewAction;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class HouseholdResource extends Resource
{
    protected static ?string $model = Household::class;

    protected static \BackedEnum|string|null $navigationIcon = 'heroicon-o-home-modern';

    protected static ?string $navigationLabel = 'Households';

    protected static ?int $navigationSort = 2;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('owner.name')
                    ->label('Owner')
                    ->searchable(),
                TextColumn::make('invite_code')
                    ->label('Invite Code')
                    ->copyable()
                    ->fontFamily('mono'),
                TextColumn::make('members_count')
                    ->label('Members')
                    ->counts('members')
                    ->sortable(),
                TextColumn::make('created_at')
                    ->label('Created')
                    ->dateTime('d M Y')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                ViewAction::make(),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListHouseholds::route('/'),
            'view'  => Pages\ViewHousehold::route('/{record}'),
        ];
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function canEdit(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDelete(\Illuminate\Database\Eloquent\Model $record): bool
    {
        return false;
    }

    public static function canDeleteAny(): bool
    {
        return false;
    }
}
